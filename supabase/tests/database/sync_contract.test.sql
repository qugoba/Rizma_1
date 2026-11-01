begin;
select plan(46);

insert into auth.users (id, is_anonymous) values
  ('11111111-1111-4111-8111-111111111111', true),
  ('22222222-2222-4222-8222-222222222222', true),
  ('33333333-3333-4333-8333-333333333333', true);

create temp table out (k text primary key, v jsonb);
grant all on out to authenticated;

set local role authenticated;
set local "request.jwt.claims" to '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}';

insert into out values ('up1', public.upload_batch('{
  "profile_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
  "profile": {"base_revision": 0, "student_code": "RZ-7K4M-9P2Q", "grade": 5,
              "color": "teal", "class_code": "GZ-5A", "equipped": "cap",
              "created_at": "2026-10-24T09:00:00Z"},
  "attempts": [
    {"id": "b0000000-0000-4000-8000-000000000001", "activity_id": "math.u1.l1.practice",
     "kind": "practice", "score": 4, "total": 5, "stars_earned": 12, "hints_used": 1,
     "details": {"questions": [{"id": "q1", "hash": "a1b2c3d4e5f60718"}]},
     "created_at": "2026-10-24T09:10:00Z"},
    {"id": "b0000000-0000-4000-8000-000000000002", "activity_id": "math.u1.l1.quiz",
     "kind": "quiz", "score": 5, "total": 5, "stars_earned": 0, "hints_used": 0,
     "details": null, "created_at": "2026-10-24T09:20:00Z"}],
  "owned_items": [{"item_id": "scarf", "cost": 20, "acquired_at": "2026-10-24T09:30:00Z"}],
  "lesson_parts": [{"lesson_id": "math.u1.l1", "part": "explanation",
                    "completed_at": "2026-10-24T09:05:00Z"}],
  "bookmarks": [{"lesson_id": "math.u1.l2", "removed_at": null,
                 "updated_at": "2026-10-24T09:06:00Z"}]
}'::jsonb));

select is((select v #>> '{profile,status}' from out where k = 'up1'), 'created',
  'أول رفع ينشئ ملف الطالب');
select is((select (v #>> '{profile,revision}')::int from out where k = 'up1'), 1,
  'بنسخة رقم 1');
select is((select jsonb_array_length(v #> '{accepted,attempts}') from out where k = 'up1'), 2,
  'المحاولتان مقبولتان');
select is((select v #> '{accepted,owned_items}' from out where k = 'up1'), '["scarf"]'::jsonb,
  'الشراء مقبول');
select is((select v #> '{accepted,lesson_parts}' from out where k = 'up1'),
  '[{"lesson_id": "math.u1.l1", "part": "explanation"}]'::jsonb,
  'إنجاز الجزء مقبول');
select is((select v #> '{accepted,bookmarks}' from out where k = 'up1'), '["math.u1.l2"]'::jsonb,
  'المفضّلة مقبولة');

insert into out values ('again', public.upload_batch('{
  "profile_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
  "attempts": [
    {"id": "b0000000-0000-4000-8000-000000000001", "activity_id": "math.u1.l1.practice",
     "kind": "practice", "score": 4, "total": 5, "stars_earned": 12, "hints_used": 1,
     "details": null, "created_at": "2026-10-24T09:10:00Z"}]
}'::jsonb));
select is((select v #> '{accepted,attempts}' from out where k = 'again'),
  '["b0000000-0000-4000-8000-000000000001"]'::jsonb,
  'المحاولة المعادة تبقى مقبولة');
select is((select count(*)::int from public.attempts), 2,
  'ولا تُحفظ مرتين (والهوية ترى أحداث طالبها تحت RLS)');
select is((select count(*)::int from public.profiles), 1, 'وترى ملفه');

insert into out values ('pull0', public.pull_changes('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 0, 500));
select is((select jsonb_array_length(v -> 'attempts') from out where k = 'pull0'), 2,
  'السحب يعيد المحاولتين');
select is((select v #>> '{profile,student_code}' from out where k = 'pull0'), 'RZ-7K4M-9P2Q',
  'ومعها ملف الطالب');
select is((select v #>> '{attempts,0,details,questions,0,hash}' from out where k = 'pull0'),
  'a1b2c3d4e5f60718', 'وبصمة السؤال محفوظة');
select is((select (v ->> 'has_more')::boolean from out where k = 'pull0'), false,
  'ولا شيء بعدها');

insert into out values ('pull1', public.pull_changes(
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  (select (v ->> 'next_cursor')::bigint from out where k = 'pull0')));
select is((select jsonb_array_length(v -> 'attempts') + jsonb_array_length(v -> 'bookmarks')
           + jsonb_array_length(v -> 'owned_items') + jsonb_array_length(v -> 'lesson_parts')
           from out where k = 'pull1'), 0,
  'السحب من المؤشر الجديد فارغ');
select is((select v -> 'next_cursor' from out where k = 'pull1'),
  (select v -> 'next_cursor' from out where k = 'pull0'),
  'والمؤشر لا يتحرك حين لا جديد');

insert into out values ('page', public.pull_changes('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 0, 2));
select is((select (v ->> 'has_more')::boolean from out where k = 'page'), true,
  'السحب على صفحات: حد الصفحة يترك has_more');

insert into out values ('upd', public.upload_batch('{
  "profile_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
  "profile": {"base_revision": 1, "grade": 6, "color": "coral", "class_code": "GZ-5A",
              "equipped": "cap"}
}'::jsonb));
select is((select v #>> '{profile,status}' from out where k = 'upd'), 'updated',
  'تعديل على آخر نسخة يُقبل');
select is((select (v #>> '{profile,revision}')::int from out where k = 'upd'), 2,
  'ويرفع revision');

insert into out values ('stale', public.upload_batch('{
  "profile_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
  "profile": {"base_revision": 1, "grade": 7, "color": "blue", "equipped": ""}
}'::jsonb));
select is((select v #>> '{profile,status}' from out where k = 'stale'), 'conflict',
  'تعديل على نسخة قديمة = تعارض');
select is((select (v #>> '{profile,profile,grade}')::int from out where k = 'stale'), 6,
  'والخادم يعيد نسخته الأحدث ولا يغيّرها');

insert into out values ('bm', public.upload_batch('{
  "profile_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
  "bookmarks": [{"lesson_id": "math.u1.l2", "removed_at": "2026-10-24T10:00:00Z",
                 "updated_at": "2026-10-24T10:00:00Z"}]
}'::jsonb));
insert into out values ('pullbm', public.pull_changes(
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  (select (v ->> 'next_cursor')::bigint from out where k = 'pull0')));
select is((select v #>> '{bookmarks,0,removed_at}' from out where k = 'pullbm') is not null, true,
  'إزالة المفضّلة تصل بالسحب');
select is((select jsonb_array_length(v -> 'attempts') from out where k = 'pullbm'), 0,
  'والأحداث القديمة لا تعود');

select throws_ok(
  $$select public.upload_batch(jsonb_build_object(
      'profile_id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      'lesson_parts', (select jsonb_agg(jsonb_build_object(
          'lesson_id', 'l' || i, 'part', 'pack', 'completed_at', '2026-10-24T10:00:00Z'))
        from generate_series(1, 201) i)))$$,
  'RZ413', 'batch_too_large', 'دفعة أكبر من 200 صف تُرفض');

set local "request.jwt.claims" to '{"sub":"33333333-3333-4333-8333-333333333333","role":"authenticated"}';

select is((select count(*)::int from public.attempts), 0,
  'هوية غير مرتبطة لا ترى شيئًا (RLS)');
select throws_ok(
  $$select public.upload_batch('{"profile_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"}')$$,
  'RZ403', 'not_linked', 'ولا تستطيع الرفع لطالب غيرها');
select throws_ok(
  $$select public.pull_changes('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')$$,
  'RZ403', 'not_linked', 'ولا السحب');
select throws_ok(
  $$insert into public.attempts (id, profile_id, activity_id, kind, score, total, created_at)
    values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'x', 'quiz', 0, 0, now())$$,
  '42501', null, 'ولا الكتابة المباشرة في الجداول');
select throws_ok(
  $$select public.upload_batch('{
    "profile_id": "dddddddd-dddd-4ddd-8ddd-dddddddddddd",
    "profile": {"base_revision": 0, "student_code": "RZ-7K4M-9P2Q", "grade": 4,
                "color": "blue", "equipped": "", "created_at": "2026-10-24T09:00:00Z"}}')$$,
  'RZ409', 'student_code_taken', 'رمز طالب مستعمل يُرفض عند إنشاء ملف جديد');
select throws_ok(
  $$select public.upload_batch('{"profile_id": "dddddddd-dddd-4ddd-8ddd-dddddddddddd"}')$$,
  'RZ404', 'profile_unknown', 'رفع لطالب غير موجود دون بيانات ملفه يُرفض');

select is(public.restore_profile('RZ-2222-2222') ->> 'status', 'wrong_code', 'رمز خاطئ');
do $$ begin perform public.restore_profile('RZ-2222-2222') from generate_series(1, 4); end $$;
select is(public.restore_profile('RZ-2222-2222') ->> 'status', 'code_locked',
  'الرمز يُقفل بعد 5 محاولات خاطئة');
do $$ begin
  perform public.restore_profile(c)
  from unnest(array['RZ-3333-3333', 'RZ-3333-4444', 'RZ-3333-5555']) c;
end $$;
select is(public.restore_profile('RZ-3333-6666') ->> 'status', 'wrong_code',
  'المحاولة الفاشلة العاشرة تُحسب');
select is(public.restore_profile('RZ-7K4M-9P2Q') ->> 'status', 'device_locked',
  'بعد 10 محاولات فاشلة تُقفل الهوية ساعة، حتى بالرمز الصحيح');

set local "request.jwt.claims" to '{"sub":"22222222-2222-4222-8222-222222222222","role":"authenticated"}';

select is(public.restore_profile(' rz7k4m9p2q ') ->> 'status', 'restored',
  'الاستعادة برمز الطالب (مهما كُتب) على هاتف جديد');
select is(jsonb_array_length(
    public.pull_changes('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 0) -> 'attempts'), 2,
  'والهاتف الجديد يسحب كل النتائج من الصفر');

select is(public.request_deletion('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'RZ-2222-2222') ->> 'status',
  'wrong_code', 'الحذف النهائي يتطلب رمز الطالب الصحيح');
select is(public.request_deletion('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'RZ-7K4M-9P2Q') ->> 'status',
  'deletion_requested', 'طلب الحذف النهائي');
select throws_ok(
  $$select public.upload_batch('{"profile_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"}')$$,
  'RZ410', 'profile_deleted', 'بعده يرفض الخادم أي رفع لهذا الطالب من أي هاتف');
select is(public.restore_profile('RZ-7K4M-9P2Q') ->> 'status', 'pending_deletion',
  'والاستعادة تقول إنه قيد الحذف');
select is(public.restore_profile('RZ-7K4M-9P2Q', true) ->> 'status', 'restored',
  'ويمكن إلغاء الحذف بالرمز خلال المهلة');
select lives_ok(
  $$select public.upload_batch('{"profile_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"}')$$,
  'بعد الإلغاء يعود الرفع');

reset role;
set local role anon;
select throws_ok(
  $$select public.pull_changes('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')$$,
  '42501', null, 'الزائر بلا هوية لا يستطيع استدعاء الدوال');

reset role;
update public.profiles set deletion_requested_at = now() - interval '15 days'
where id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
insert into public.profiles (id, student_code, grade, color, created_at, last_activity_at)
values ('cccccccc-cccc-4ccc-8ccc-cccccccccccc', 'RZ-AAAA-BBBB', 3, 'amber', now(),
        now() - interval '25 months');
insert into auth.users (id, is_anonymous, created_at) values
  ('44444444-4444-4444-8444-444444444444', true, now() - interval '40 days');

insert into out values ('maint', private.run_maintenance());
select is((select (v ->> 'deleted_profiles')::int from out where k = 'maint'), 1,
  'الصيانة تمسح الملف بعد انتهاء مهلة الـ 14 يومًا');
select is((select (v ->> 'inactive_profiles')::int from out where k = 'maint'), 1,
  'وتمسح الملف بلا نشاط منذ أكثر من 24 شهرًا');
select is((select count(*)::int from public.attempts), 0, 'ومع الملف تُمسح كل أحداثه');
select is((select v ->> 'orphan_users' from out where k = 'maint'), '1',
  'وتحذف الهوية المجهولة اليتيمة الأقدم من 30 يومًا فقط');

select * from finish();
rollback;
