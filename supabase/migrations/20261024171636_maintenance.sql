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
