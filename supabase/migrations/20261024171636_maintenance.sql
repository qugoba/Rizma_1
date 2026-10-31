-- رِزمة — الصيانة اليومية (ADR 6.4 و7 و8). تعمل مرة في اليوم عبر pg_cron.
--
-- 1. حذف الملفات التي طُلب حذفها نهائيًا منذ 14 يومًا (المهلة انتهت).
-- 2. حذف الملفات بلا أي نشاط منذ 24 شهرًا (النشاط = رفع أو سحب أو استعادة من
--    أي جهاز مرتبط). 24 لا 12 بسبب النزوح.
-- 3. حذف الهويات المجهولة اليتيمة: بلا طالب مرتبط، وعمرها أكثر من 30 يومًا.
-- 4. تنظيف سجلات حدود التخمين القديمة.
--
-- حذف الملف يحذف كل أحداثه وروابط أجهزته (on delete cascade).

create function private.run_maintenance()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deleted integer;
  v_inactive integer;
  v_orphans integer;
begin
  delete from public.profiles
  where deletion_requested_at < now() - interval '14 days';
  get diagnostics v_deleted = row_count;

  delete from public.profiles
  where last_activity_at < now() - interval '24 months';
  get diagnostics v_inactive = row_count;

  delete from auth.users u
  where u.is_anonymous
    and u.created_at < now() - interval '30 days'
    and not exists (
      select 1 from public.profile_devices d where d.user_id = u.id
    );
  get diagnostics v_orphans = row_count;

  delete from public.restore_code_failures
  where last_failure_at < now() - interval '1 day'
    and (locked_until is null or locked_until < now());
  delete from public.restore_device_failures
  where window_started_at < now() - interval '1 day'
    and (locked_until is null or locked_until < now());

  return jsonb_build_object(
    'deleted_profiles', v_deleted,
    'inactive_profiles', v_inactive,
    'orphan_users', v_orphans
  );
end;
$$;

revoke all on function private.run_maintenance() from public, anon, authenticated;

-- الجدولة: 3:17 فجرًا بتوقيت الخادم كل يوم. تحتاج إضافة pg_cron مفعّلة في
-- Supabase (Database ← Extensions). إن لم تكن مفعّلة يُتخطّى هذا الجزء دون خطأ،
-- ويُشغَّل لاحقًا بالسطر نفسه من محرر SQL (انظر README).
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule(
      'rizma-maintenance',
      '17 3 * * *',
      'select private.run_maintenance()'
    );
  end if;
end;
$$;
