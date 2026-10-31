-- رِزمة — جداول الخادم (ADR 001: docs/adr/001-sync-and-schema.md).
--
-- الخادم نسخة احتياطية من بيانات الطالب لا مصدرها: الهاتف يعمل كاملًا دونه.
-- لا اسم ولا رقم سري ولا بريد ولا رقم هاتف هنا أبدًا.
--
-- قاعدة الكتابة (ADR 5.1): لا أحد يكتب في هذه الجداول مباشرة. كل كتابة تمر
-- بدوال الملف التالي (20261024171604_functions.sql)، وهي تأخذ قفل الطالب أولًا
-- ثم تحجز `server_seq`. الهوية (`authenticated`) تقرأ فقط، وفقط طلابها.

-- ─────────────────────────────────────────────────────────────────────────────
-- رقم تسلسلي واحد للخادم كله: كل صف يُكتب أو يُعدَّل يأخذ رقمًا جديدًا.
-- الهاتف يسحب «كل ما رقمه أكبر من مؤشري» لكل طالب (ADR 6.1). مسموح هنا لأنه
-- يُنشأ على الخادم وحده ولا يُستعمل مفتاحًا.
create sequence public.server_seq as bigint;

-- ─────────────────────────────────────────────────────────────────────────────
-- ملف الطالب: ما ينتقل معه إلى أجهزته الأخرى. صف «يتغيّر»: `revision` يزيد مع
-- كل تعديل مقبول ويحسم التعارض (ADR 4).
create table public.profiles (
  id uuid primary key,
  student_code text not null unique
    check (student_code ~ '^RZ-[2-9A-HJKMNP-Z]{4}-[2-9A-HJKMNP-Z]{4}$'),
  grade smallint not null check (grade between 1 and 12),
  color text not null
    check (color in ('teal', 'coral', 'blue', 'purple', 'amber')),
  class_code text check (class_code is null or char_length(class_code) <= 16),
  -- معرّفات قطع الخزانة المرتداة مفصولة بفواصل (نفس ترميز الهاتف).
  equipped text not null default '' check (char_length(equipped) <= 500),
  -- وقت الهاتف عند إنشاء الملف.
  created_at timestamptz not null,
  revision integer not null default 1 check (revision >= 1),
  server_seq bigint not null default nextval('public.server_seq'),
  server_received_at timestamptz not null default now(),
  -- آخر رفع أو سحب أو استعادة؛ منه الحذف التلقائي بعد 24 شهرًا (ADR 6.4).
  last_activity_at timestamptz not null default now(),
  -- طلب «الحذف النهائي من كل مكان»: يختفي فورًا ويُمسح بعد 14 يومًا (ADR 8).
  deletion_requested_at timestamptz
);

-- الأجهزة (الهويات المجهولة) المرتبطة بكل طالب. منها قواعد الحماية: كل هوية
-- ترى طلابها فقط. حذف الهوية يفك ربطها.
create table public.profile_devices (
  profile_id uuid not null references public.profiles (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  linked_at timestamptz not null default now(),
  primary key (profile_id, user_id)
);
create index profile_devices_user_idx on public.profile_devices (user_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- أحداث لا تتغيّر بعد حفظها (ADR 4): تُدخل مرة واحدة ويُتجاهل مكررها بالمفتاح.

create table public.attempts (
  -- UUID من الهاتف.
  id uuid primary key,
  profile_id uuid not null references public.profiles (id) on delete cascade,
  activity_id text not null check (char_length(activity_id) <= 200),
  kind text not null check (kind in ('practice', 'quiz')),
  score integer not null check (score >= 0),
  total integer not null check (total >= 0 and score <= total),
  stars_earned integer not null default 0 check (stars_earned >= 0),
  hints_used integer not null default 0 check (hints_used >= 0),
  -- نتيجة كل سؤال مع بصمة محتواه (null لجولات الألعاب).
  details jsonb,
  -- وقت الهاتف.
  created_at timestamptz not null,
  server_seq bigint not null default nextval('public.server_seq'),
  server_received_at timestamptz not null default now()
);

create table public.owned_items (
  profile_id uuid not null references public.profiles (id) on delete cascade,
  item_id text not null check (char_length(item_id) <= 100),
  cost integer not null check (cost >= 0),
  acquired_at timestamptz not null,
  server_seq bigint not null default nextval('public.server_seq'),
  server_received_at timestamptz not null default now(),
  primary key (profile_id, item_id)
);

create table public.lesson_parts (
  profile_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id text not null check (char_length(lesson_id) <= 200),
  part text not null check (
    part in ('pack', 'explanation', 'summary', 'video', 'words', 'practice', 'quiz')
  ),
  completed_at timestamptz not null,
  server_seq bigint not null default nextval('public.server_seq'),
  server_received_at timestamptz not null default now(),
  primary key (profile_id, lesson_id, part)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- المفضّلة: صف «يتغيّر» بعلامة حذف `removed_at` (ADR 6.2). عند التعارض يفوز آخر
-- تغيير استلمه الخادم، أي `server_seq` الأكبر.
create table public.bookmarks (
  profile_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id text not null check (char_length(lesson_id) <= 200),
  removed_at timestamptz,
  updated_at timestamptz not null,
  server_seq bigint not null default nextval('public.server_seq'),
  server_received_at timestamptz not null default now(),
  primary key (profile_id, lesson_id)
);

-- فهارس السحب: «صفوف هذا الطالب التي رقمها أكبر من المؤشر».
create index profiles_seq_idx on public.profiles (id, server_seq);
create index attempts_seq_idx on public.attempts (profile_id, server_seq);
create index owned_items_seq_idx on public.owned_items (profile_id, server_seq);
create index lesson_parts_seq_idx on public.lesson_parts (profile_id, server_seq);
create index bookmarks_seq_idx on public.bookmarks (profile_id, server_seq);

-- ─────────────────────────────────────────────────────────────────────────────
-- حدود التخمين في الاستعادة (ADR 3): 5 محاولات خاطئة على نفس الرمز تقفله 15
-- دقيقة، و10 محاولات فاشلة من نفس الهوية خلال ساعة تقفلها ساعة. لا شيء على
-- عنوان الإنترنت. الرمز لا يُخزَّن هنا، بصمته فقط.
create table public.restore_code_failures (
  code_hash text primary key,
  failures integer not null default 0,
  last_failure_at timestamptz not null default now(),
  locked_until timestamptz
);

create table public.restore_device_failures (
  user_id uuid primary key references auth.users (id) on delete cascade,
  failures integer not null default 0,
  window_started_at timestamptz not null default now(),
  locked_until timestamptz
);

-- ─────────────────────────────────────────────────────────────────────────────
-- الصلاحيات وقواعد الحماية (RLS).
-- Supabase يعطي anon وauthenticated كل الصلاحيات على جداول public افتراضيًا،
-- فنسحبها صراحة ثم نعطي القراءة فقط لجداول الطالب، وRLS يحصرها في طلاب الهوية.

revoke all on all tables in schema public from anon, authenticated;
revoke all on sequence public.server_seq from anon, authenticated;

alter table public.profiles enable row level security;
alter table public.profile_devices enable row level security;
alter table public.attempts enable row level security;
alter table public.owned_items enable row level security;
alter table public.lesson_parts enable row level security;
alter table public.bookmarks enable row level security;
alter table public.restore_code_failures enable row level security;
alter table public.restore_device_failures enable row level security;

grant select on
  public.profiles,
  public.profile_devices,
  public.attempts,
  public.owned_items,
  public.lesson_parts,
  public.bookmarks
to authenticated;

create policy "own devices" on public.profile_devices
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy "linked students" on public.profiles
  for select to authenticated
  using (
    deletion_requested_at is null
    and exists (
      select 1 from public.profile_devices d
      where d.profile_id = profiles.id and d.user_id = (select auth.uid())
    )
  );

create policy "linked students" on public.attempts
  for select to authenticated
  using (exists (
    select 1 from public.profile_devices d
    where d.profile_id = attempts.profile_id and d.user_id = (select auth.uid())
  ));

create policy "linked students" on public.owned_items
  for select to authenticated
  using (exists (
    select 1 from public.profile_devices d
    where d.profile_id = owned_items.profile_id and d.user_id = (select auth.uid())
  ));

create policy "linked students" on public.lesson_parts
  for select to authenticated
  using (exists (
    select 1 from public.profile_devices d
    where d.profile_id = lesson_parts.profile_id and d.user_id = (select auth.uid())
  ));

create policy "linked students" on public.bookmarks
  for select to authenticated
  using (exists (
    select 1 from public.profile_devices d
    where d.profile_id = bookmarks.profile_id and d.user_id = (select auth.uid())
  ));

-- جدولا حدود التخمين: لا قواعد = لا وصول لأي هوية. الدوال وحدها تكتب فيهما.
