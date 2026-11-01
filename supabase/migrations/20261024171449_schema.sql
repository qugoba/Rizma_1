create sequence public.server_seq as bigint;

create table public.profiles (
  id uuid primary key,
  student_code text not null unique
    check (student_code ~ '^RZ-[2-9A-HJKMNP-Z]{4}-[2-9A-HJKMNP-Z]{4}$'),
  grade smallint not null check (grade between 1 and 12),
  color text not null
    check (color in ('teal', 'coral', 'blue', 'purple', 'amber')),
  class_code text check (class_code is null or char_length(class_code) <= 16),
  equipped text not null default '' check (char_length(equipped) <= 500),
  created_at timestamptz not null,
  revision integer not null default 1 check (revision >= 1),
  server_seq bigint not null default nextval('public.server_seq'),
  server_received_at timestamptz not null default now(),
  last_activity_at timestamptz not null default now(),
  deletion_requested_at timestamptz
);

create table public.profile_devices (
  profile_id uuid not null references public.profiles (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  linked_at timestamptz not null default now(),
  primary key (profile_id, user_id)
);
create index profile_devices_user_idx on public.profile_devices (user_id);

create table public.attempts (
  id uuid primary key,
  profile_id uuid not null references public.profiles (id) on delete cascade,
  activity_id text not null check (char_length(activity_id) <= 200),
  kind text not null check (kind in ('practice', 'quiz')),
  score integer not null check (score >= 0),
  total integer not null check (total >= 0 and score <= total),
  stars_earned integer not null default 0 check (stars_earned >= 0),
  hints_used integer not null default 0 check (hints_used >= 0),
  details jsonb,
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

create table public.bookmarks (
  profile_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id text not null check (char_length(lesson_id) <= 200),
  removed_at timestamptz,
  updated_at timestamptz not null,
  server_seq bigint not null default nextval('public.server_seq'),
  server_received_at timestamptz not null default now(),
  primary key (profile_id, lesson_id)
);

create index profiles_seq_idx on public.profiles (id, server_seq);
create index attempts_seq_idx on public.attempts (profile_id, server_seq);
create index owned_items_seq_idx on public.owned_items (profile_id, server_seq);
create index lesson_parts_seq_idx on public.lesson_parts (profile_id, server_seq);
create index bookmarks_seq_idx on public.bookmarks (profile_id, server_seq);

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

