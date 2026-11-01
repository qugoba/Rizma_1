create schema if not exists private;
revoke all on schema private from public;

create function private.require_user()
returns uuid
language plpgsql
stable
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = 'RZ401';
  end if;
  return v_uid;
end;
$$;

create function private.lock_profile(p_profile_id uuid)
returns void
language sql
set search_path = ''
as $$
  select pg_advisory_xact_lock(hashtextextended('rizma.profile:' || p_profile_id::text, 0));
$$;

create function private.normalize_code(p_code text)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when compact ~ '^RZ.{8}$'
      then 'RZ-' || substr(compact, 3, 4) || '-' || substr(compact, 7, 4)
    else compact
  end
  from (select upper(regexp_replace(coalesce(p_code, ''), '[[:space:]-]', '', 'g')) as compact) c;
$$;

create function private.code_hash(p_code text)
returns text
language sql
immutable
set search_path = ''
as $$
  select encode(sha256(convert_to(p_code, 'UTF8')), 'hex');
$$;

create function private.assert_access(p_profile_id uuid, p_uid uuid)
returns void
language plpgsql
stable
set search_path = ''
as $$
declare
  v_deleted timestamptz;
begin
  select deletion_requested_at into v_deleted
  from public.profiles where id = p_profile_id;
  if not found then
    raise exception 'profile_unknown' using errcode = 'RZ404';
  end if;
  if v_deleted is not null then
    raise exception 'profile_deleted' using errcode = 'RZ410';
  end if;
  if not exists (
    select 1 from public.profile_devices
    where profile_id = p_profile_id and user_id = p_uid
  ) then
    raise exception 'not_linked' using errcode = 'RZ403';
  end if;
end;
$$;

create function private.profile_json(p public.profiles)
returns jsonb
language sql
stable
set search_path = ''
as $$
  select jsonb_build_object(
    'id', p.id,
    'student_code', p.student_code,
    'grade', p.grade,
    'color', p.color,
    'class_code', p.class_code,
    'equipped', p.equipped,
    'created_at', p.created_at,
    'revision', p.revision,
    'server_seq', p.server_seq,
    'server_received_at', p.server_received_at
  );
$$;

create function private.record_code_failure(p_code_hash text)
returns void
language plpgsql
set search_path = ''
as $$
declare
  v_failures integer;
begin
  insert into public.restore_code_failures as f (code_hash, failures, last_failure_at)
  values (p_code_hash, 1, now())
  on conflict (code_hash) do update set
    failures = case when f.locked_until is not null then 1 else f.failures + 1 end,
    locked_until = null,
    last_failure_at = now()
  returning failures into v_failures;

  if v_failures >= 5 then
    update public.restore_code_failures
    set locked_until = now() + interval '15 minutes', failures = 0
    where code_hash = p_code_hash;
  end if;
end;
$$;

create function private.record_device_failure(p_uid uuid)
returns void
language plpgsql
set search_path = ''
as $$
declare
  v_failures integer;
begin
  insert into public.restore_device_failures as d (user_id, failures, window_started_at)
  values (p_uid, 1, now())
  on conflict (user_id) do update set
    failures = case
      when d.locked_until is not null or d.window_started_at < now() - interval '1 hour'
        then 1
      else d.failures + 1
    end,
    window_started_at = case
      when d.locked_until is not null or d.window_started_at < now() - interval '1 hour'
        then now()
      else d.window_started_at
    end,
    locked_until = null
  returning failures into v_failures;

  if v_failures >= 10 then
    update public.restore_device_failures
    set locked_until = now() + interval '1 hour', failures = 0
    where user_id = p_uid;
  end if;
end;
$$;

create function public.upload_batch(p_batch jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := private.require_user();
  v_profile_id uuid;
  v_profile jsonb;
  v_current public.profiles;
  v_profile_result jsonb := null;
  v_rows integer;
  v_attempts jsonb;
  v_owned jsonb;
  v_parts jsonb;
  v_bookmarks jsonb;
begin
  if p_batch is null or jsonb_typeof(p_batch) <> 'object'
     or (p_batch ->> 'profile_id') is null then
    raise exception 'bad_batch' using errcode = 'RZ400';
  end if;
  v_profile_id := (p_batch ->> 'profile_id')::uuid;
  v_profile := p_batch -> 'profile';
  if jsonb_typeof(v_profile) = 'null' then
    v_profile := null;
  end if;
  v_attempts := coalesce(p_batch -> 'attempts', '[]'::jsonb);
  v_owned := coalesce(p_batch -> 'owned_items', '[]'::jsonb);
  v_parts := coalesce(p_batch -> 'lesson_parts', '[]'::jsonb);
  v_bookmarks := coalesce(p_batch -> 'bookmarks', '[]'::jsonb);

  v_rows := jsonb_array_length(v_attempts) + jsonb_array_length(v_owned)
    + jsonb_array_length(v_parts) + jsonb_array_length(v_bookmarks);
  if v_rows > 200 or octet_length(p_batch::text) > 300000 then
    raise exception 'batch_too_large' using errcode = 'RZ413';
  end if;

  perform private.lock_profile(v_profile_id);

  select * into v_current from public.profiles where id = v_profile_id;

  if not found then
    if v_profile is null then
      raise exception 'profile_unknown' using errcode = 'RZ404';
    end if;
    begin
      insert into public.profiles (
        id, student_code, grade, color, class_code, equipped, created_at
      ) values (
        v_profile_id,
        v_profile ->> 'student_code',
        (v_profile ->> 'grade')::smallint,
        v_profile ->> 'color',
        nullif(v_profile ->> 'class_code', ''),
        coalesce(v_profile ->> 'equipped', ''),
        (v_profile ->> 'created_at')::timestamptz
      )
      returning * into v_current;
    exception when unique_violation then
      raise exception 'student_code_taken' using errcode = 'RZ409';
    end;
    insert into public.profile_devices (profile_id, user_id)
    values (v_profile_id, v_uid);
    v_profile_result := jsonb_build_object(
      'status', 'created', 'revision', v_current.revision
    );
  else
    perform private.assert_access(v_profile_id, v_uid);
    if v_profile is not null then
      if (v_profile ->> 'base_revision')::integer = v_current.revision then
        update public.profiles set
          grade = (v_profile ->> 'grade')::smallint,
          color = v_profile ->> 'color',
          class_code = nullif(v_profile ->> 'class_code', ''),
          equipped = coalesce(v_profile ->> 'equipped', ''),
          revision = revision + 1,
          server_seq = nextval('public.server_seq'),
          server_received_at = now()
        where id = v_profile_id
        returning * into v_current;
        v_profile_result := jsonb_build_object(
          'status', 'updated', 'revision', v_current.revision
        );
      else
        v_profile_result := jsonb_build_object(
          'status', 'conflict',
          'revision', v_current.revision,
          'profile', private.profile_json(v_current)
        );
      end if;
    end if;
  end if;

  insert into public.attempts (
    id, profile_id, activity_id, kind, score, total,
    stars_earned, hints_used, details, created_at
  )
  select r.id, v_profile_id, r.activity_id, r.kind, r.score, r.total,
    coalesce(r.stars_earned, 0), coalesce(r.hints_used, 0), r.details, r.created_at
  from jsonb_to_recordset(v_attempts) as r(
    id uuid, activity_id text, kind text, score integer, total integer,
    stars_earned integer, hints_used integer, details jsonb, created_at timestamptz
  )
  on conflict (id) do nothing;

  insert into public.owned_items (profile_id, item_id, cost, acquired_at)
  select v_profile_id, r.item_id, r.cost, r.acquired_at
  from jsonb_to_recordset(v_owned) as r(
    item_id text, cost integer, acquired_at timestamptz
  )
  on conflict (profile_id, item_id) do nothing;

  insert into public.lesson_parts (profile_id, lesson_id, part, completed_at)
  select v_profile_id, r.lesson_id, r.part, r.completed_at
  from jsonb_to_recordset(v_parts) as r(
    lesson_id text, part text, completed_at timestamptz
  )
  on conflict (profile_id, lesson_id, part) do nothing;

  insert into public.bookmarks (profile_id, lesson_id, removed_at, updated_at)
  select distinct on (r.lesson_id)
    v_profile_id, r.lesson_id, r.removed_at, r.updated_at
  from jsonb_to_recordset(v_bookmarks) as r(
    lesson_id text, removed_at timestamptz, updated_at timestamptz
  )
  order by r.lesson_id, r.updated_at desc
  on conflict (profile_id, lesson_id) do update set
    removed_at = excluded.removed_at,
    updated_at = excluded.updated_at,
    server_seq = nextval('public.server_seq'),
    server_received_at = now();

  update public.profiles set last_activity_at = now() where id = v_profile_id;

  return jsonb_build_object(
    'profile', v_profile_result,
    'accepted', jsonb_build_object(
      'attempts', (
        select coalesce(jsonb_agg(a.id), '[]'::jsonb)
        from public.attempts a
        where a.profile_id = v_profile_id
          and a.id in (select (e ->> 'id')::uuid from jsonb_array_elements(v_attempts) e)
      ),
      'owned_items', (
        select coalesce(jsonb_agg(o.item_id), '[]'::jsonb)
        from public.owned_items o
        where o.profile_id = v_profile_id
          and o.item_id in (select e ->> 'item_id' from jsonb_array_elements(v_owned) e)
      ),
      'lesson_parts', (
        select coalesce(
          jsonb_agg(jsonb_build_object('lesson_id', l.lesson_id, 'part', l.part)),
          '[]'::jsonb
        )
        from public.lesson_parts l
        where l.profile_id = v_profile_id
          and (l.lesson_id, l.part) in (
            select e ->> 'lesson_id', e ->> 'part' from jsonb_array_elements(v_parts) e
          )
      ),
      'bookmarks', (
        select coalesce(jsonb_agg(distinct e ->> 'lesson_id'), '[]'::jsonb)
        from jsonb_array_elements(v_bookmarks) e
      )
    )
  );
end;
$$;

create function public.pull_changes(
  p_profile_id uuid,
  p_cursor bigint default 0,
  p_limit integer default 500
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := private.require_user();
  v_cursor bigint := coalesce(p_cursor, 0);
  v_limit integer := least(greatest(coalesce(p_limit, 500), 1), 1000);
  v_upto bigint;
  v_more boolean;
begin
  perform private.assert_access(p_profile_id, v_uid);

  select max(s) into v_upto
  from (
    select s from (
      select server_seq as s from public.profiles
        where id = p_profile_id and server_seq > v_cursor
      union all select server_seq from public.attempts
        where profile_id = p_profile_id and server_seq > v_cursor
      union all select server_seq from public.owned_items
        where profile_id = p_profile_id and server_seq > v_cursor
      union all select server_seq from public.lesson_parts
        where profile_id = p_profile_id and server_seq > v_cursor
      union all select server_seq from public.bookmarks
        where profile_id = p_profile_id and server_seq > v_cursor
    ) all_rows
    order by s
    limit v_limit
  ) page;

  update public.profiles set last_activity_at = now() where id = p_profile_id;

  if v_upto is null then
    return jsonb_build_object(
      'profile', null,
      'attempts', '[]'::jsonb,
      'owned_items', '[]'::jsonb,
      'lesson_parts', '[]'::jsonb,
      'bookmarks', '[]'::jsonb,
      'next_cursor', v_cursor,
      'has_more', false
    );
  end if;

  v_more := exists (select 1 from public.attempts where profile_id = p_profile_id and server_seq > v_upto)
    or exists (select 1 from public.owned_items where profile_id = p_profile_id and server_seq > v_upto)
    or exists (select 1 from public.lesson_parts where profile_id = p_profile_id and server_seq > v_upto)
    or exists (select 1 from public.bookmarks where profile_id = p_profile_id and server_seq > v_upto)
    or exists (select 1 from public.profiles where id = p_profile_id and server_seq > v_upto);

  return jsonb_build_object(
    'profile', (
      select private.profile_json(p) from public.profiles p
      where p.id = p_profile_id and p.server_seq > v_cursor and p.server_seq <= v_upto
    ),
    'attempts', (
      select coalesce(jsonb_agg(to_jsonb(a) - 'profile_id' order by a.server_seq), '[]'::jsonb)
      from public.attempts a
      where a.profile_id = p_profile_id and a.server_seq > v_cursor and a.server_seq <= v_upto
    ),
    'owned_items', (
      select coalesce(jsonb_agg(to_jsonb(o) - 'profile_id' order by o.server_seq), '[]'::jsonb)
      from public.owned_items o
      where o.profile_id = p_profile_id and o.server_seq > v_cursor and o.server_seq <= v_upto
    ),
    'lesson_parts', (
      select coalesce(jsonb_agg(to_jsonb(l) - 'profile_id' order by l.server_seq), '[]'::jsonb)
      from public.lesson_parts l
      where l.profile_id = p_profile_id and l.server_seq > v_cursor and l.server_seq <= v_upto
    ),
    'bookmarks', (
      select coalesce(jsonb_agg(to_jsonb(b) - 'profile_id' order by b.server_seq), '[]'::jsonb)
      from public.bookmarks b
      where b.profile_id = p_profile_id and b.server_seq > v_cursor and b.server_seq <= v_upto
    ),
    'next_cursor', v_upto,
    'has_more', v_more
  );
end;
$$;

create function public.restore_profile(
  p_code text,
  p_cancel_deletion boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := private.require_user();
  v_code text := private.normalize_code(p_code);
  v_hash text := private.code_hash(private.normalize_code(p_code));
  v_locked_until timestamptz;
  v_profile public.profiles;
begin
  select locked_until into v_locked_until
  from public.restore_device_failures where user_id = v_uid;
  if v_locked_until > now() then
    return jsonb_build_object('status', 'device_locked', 'retry_at', v_locked_until);
  end if;

  select locked_until into v_locked_until
  from public.restore_code_failures where code_hash = v_hash;
  if v_locked_until > now() then
    perform private.record_device_failure(v_uid);
    return jsonb_build_object('status', 'code_locked', 'retry_at', v_locked_until);
  end if;

  select * into v_profile from public.profiles where student_code = v_code;
  if not found then
    perform private.record_code_failure(v_hash);
    perform private.record_device_failure(v_uid);
    return jsonb_build_object('status', 'wrong_code');
  end if;

  delete from public.restore_code_failures where code_hash = v_hash;

  if v_profile.deletion_requested_at is not null then
    if not coalesce(p_cancel_deletion, false) then
      return jsonb_build_object(
        'status', 'pending_deletion',
        'profile_id', v_profile.id,
        'purge_at', v_profile.deletion_requested_at + interval '14 days'
      );
    end if;
    perform private.lock_profile(v_profile.id);
    update public.profiles set deletion_requested_at = null where id = v_profile.id;
  end if;

  insert into public.profile_devices (profile_id, user_id)
  values (v_profile.id, v_uid)
  on conflict do nothing;
  update public.profiles set last_activity_at = now() where id = v_profile.id;

  return jsonb_build_object('status', 'restored', 'profile_id', v_profile.id);
end;
$$;

create function public.request_deletion(p_profile_id uuid, p_code text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := private.require_user();
  v_code text;
begin
  perform private.lock_profile(p_profile_id);
  perform private.assert_access(p_profile_id, v_uid);

  select student_code into v_code from public.profiles where id = p_profile_id;
  if v_code <> private.normalize_code(p_code) then
    return jsonb_build_object('status', 'wrong_code');
  end if;

  update public.profiles
  set deletion_requested_at = now(), last_activity_at = now()
  where id = p_profile_id;

  return jsonb_build_object(
    'status', 'deletion_requested',
    'purge_at', now() + interval '14 days'
  );
end;
$$;

create function public.unlink_device(p_profile_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := private.require_user();
begin
  delete from public.profile_devices
  where profile_id = p_profile_id and user_id = v_uid;
end;
$$;

revoke execute on all functions in schema public from public, anon, authenticated;
revoke all on all functions in schema private from public, anon, authenticated;

grant execute on function
  public.upload_batch(jsonb),
  public.pull_changes(uuid, bigint, integer),
  public.restore_profile(text, boolean),
  public.request_deletion(uuid, text),
  public.unlink_device(uuid)
to authenticated;
