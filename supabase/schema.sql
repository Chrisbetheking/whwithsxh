-- ============================================================
-- whwithsxh · Supabase 数据库结构（完整可重放脚本）
-- ============================================================
-- 用途：
--   1. 备份 / 迁移：换一个 Supabase 项目时，把本文件整体粘到
--      Supabase 控制台 → SQL Editor 执行即可重建全部结构。
--   2. 留档：记录表结构、RLS 策略、触发器的最终状态。
--
-- 执行方式（任选其一）：
--   A. Supabase Dashboard → SQL Editor → 新建查询 → 粘贴 → Run
--   B. 使用 Supabase MCP 的 apply_migration（AI 助手场景）
--
-- ⚠️ 注意：末尾「创建两个账号」一节含密码哈希，请勿公开分享本文件。
--    如果你只想建表，执行到「第 7 节」即可，跳过账号创建。
-- ============================================================


-- ============================================================
-- 第 1 节：信件表 letters
-- ============================================================
create table if not exists public.letters (
  id           uuid primary key default gen_random_uuid(),
  -- 写信人，限定为两人之一
  author       text not null check (author in ('wanghong', 'songxinghe')),
  title        text not null,
  content      text default '',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  is_published boolean not null default true
);

comment on table  public.letters is '两个人写给对方的信';
comment on column public.letters.author is 'wanghong=王鸿，songxinghe=宋星禾';
comment on column public.letters.is_published is 'false 表示草稿，前端列表不展示';


-- ============================================================
-- 第 2 节：时间线表 timeline
-- ============================================================
create table if not exists public.timeline (
  id          uuid primary key default gen_random_uuid(),
  date        date,
  title       text,
  description text,      -- 可留空
  author      text
);

comment on table public.timeline is '我们的时间线：值得记住的日子';


-- ============================================================
-- 第 3 节：索引
-- ============================================================
create index if not exists letters_created_at_idx on public.letters (created_at desc);
create index if not exists timeline_date_idx      on public.timeline (date asc);


-- ============================================================
-- 第 4 节：updated_at 自动维护
-- ============================================================
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists letters_set_updated_at on public.letters;
create trigger letters_set_updated_at
  before update on public.letters
  for each row
  execute function public.set_updated_at();


-- ============================================================
-- 第 5 节：启用 RLS（行级安全）
-- ============================================================
-- 启用后默认拒绝一切访问，必须由策略显式放行。
alter table public.letters  enable row level security;
alter table public.timeline enable row level security;


-- ============================================================
-- 第 6 节：RLS 策略
-- ============================================================
-- 安全模型（两层）：
--   第 1 层 GRANT：anon 角色被收回全部权限 → 未登录连表都摸不到；
--   第 2 层 RLS  ：即使拿到 authenticated 角色，也必须 auth.uid()
--                  命中下面两个 UUID 才放行。
--
-- 🔧 维护提示：若重建账号，UUID 会变。执行
--       select id, email from auth.users;
--    查出新 UUID 后，替换本节所有 'xxx'::uuid 常量。
-- ============================================================

-- ---------- letters ----------
drop policy if exists "letters_auth_select" on public.letters;
drop policy if exists "letters_auth_insert" on public.letters;
drop policy if exists "letters_auth_update" on public.letters;
drop policy if exists "letters_auth_delete" on public.letters;

create policy "letters_auth_select" on public.letters
  for select to authenticated
  using (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,   -- 王鸿
                        '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid));  -- 宋星禾

create policy "letters_auth_insert" on public.letters
  for insert to authenticated
  with check (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,
                             '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid));

create policy "letters_auth_update" on public.letters
  for update to authenticated
  using (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,
                        '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid))
  with check (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,
                             '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid));

create policy "letters_auth_delete" on public.letters
  for delete to authenticated
  using (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,
                        '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid));

-- ---------- timeline ----------
drop policy if exists "timeline_auth_select" on public.timeline;
drop policy if exists "timeline_auth_insert" on public.timeline;
drop policy if exists "timeline_auth_update" on public.timeline;
drop policy if exists "timeline_auth_delete" on public.timeline;

create policy "timeline_auth_select" on public.timeline
  for select to authenticated
  using (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,
                        '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid));

create policy "timeline_auth_insert" on public.timeline
  for insert to authenticated
  with check (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,
                             '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid));

create policy "timeline_auth_update" on public.timeline
  for update to authenticated
  using (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,
                        '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid))
  with check (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,
                             '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid));

create policy "timeline_auth_delete" on public.timeline
  for delete to authenticated
  using (auth.uid() in ('8187a9d0-0858-4966-9b88-9f7d2c0705dd'::uuid,
                        '86dc88ef-1fe0-4081-80b4-c812892b4db6'::uuid));


-- ============================================================
-- 第 7 节：表级权限（GRANT / REVOKE）
-- ============================================================
grant select, insert, update, delete on public.letters  to authenticated;
grant select, insert, update, delete on public.timeline to authenticated;

-- 关键：把 anon 的权限全部收回，未登录用户一点数据都读不到
revoke all on public.letters  from anon;
revoke all on public.timeline from anon;


-- ============================================================
-- 第 8 节：示例数据（可按需删除）
-- ============================================================
insert into public.letters (author, title, content) values
  ('wanghong',   '第一封信', '（待填写）'),
  ('wanghong',   '第二封信', '（待填写）'),
  ('songxinghe', '第一封信', '（待填写）');

insert into public.timeline (date, title, description, author) values
  ('2026-09-07', '我们在一起了', '从这一天开始，成都和自贡之间有了牵挂。', 'wanghong');


-- ============================================================
-- 第 9 节：创建两个账号（王鸿 / 宋星禾）
-- ============================================================
-- 说明：
--   - 本站不提供注册入口，账号只能在此创建或到 Dashboard 手动添加；
--   - 密码用 bcrypt 哈希存储（与 Supabase Auth 内部一致）；
--   - 初始密码：whwithsxh0907   ← 请登录后尽快修改；
--   - 同时写入 auth.identities，否则密码登录会报「凭据无效」。
--
-- ⚠️ 若你已经在 Dashboard 建过账号，请跳过本节，避免重复创建。
-- ============================================================

do $$
declare
  uid_wang  uuid := gen_random_uuid();
  uid_song  uuid := gen_random_uuid();
  init_pwd  text := 'whwithsxh0907';   -- ← 改这里可以换初始密码
begin
  -- ---------- 王鸿 ----------
  if not exists (select 1 from auth.users where email = 'wanghong@whwithsxh.local') then
    insert into auth.users (
      id, instance_id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data,
      confirmation_token, recovery_token,
      email_change, email_change_token_new, email_change_token_current
    ) values (
      uid_wang,
      '00000000-0000-0000-0000-000000000000',
      'authenticated', 'authenticated',
      'wanghong@whwithsxh.local',
      extensions.crypt(init_pwd, extensions.gen_salt('bf')),
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"display_name":"王鸿"}'::jsonb,
      '', '', '', '', ''
    );

    insert into auth.identities (
      id, user_id, provider_id, provider, identity_data,
      last_sign_in_at, created_at, updated_at
    ) values (
      gen_random_uuid(), uid_wang, 'wanghong@whwithsxh.local', 'email',
      jsonb_build_object('sub', uid_wang::text, 'email', 'wanghong@whwithsxh.local', 'email_verified', true),
      now(), now(), now()
    );
  end if;

  -- ---------- 宋星禾 ----------
  if not exists (select 1 from auth.users where email = 'songxinghe@whwithsxh.local') then
    insert into auth.users (
      id, instance_id, aud, role, email, encrypted_password,
      email_confirmed_at, created_at, updated_at,
      raw_app_meta_data, raw_user_meta_data,
      confirmation_token, recovery_token,
      email_change, email_change_token_new, email_change_token_current
    ) values (
      uid_song,
      '00000000-0000-0000-0000-000000000000',
      'authenticated', 'authenticated',
      'songxinghe@whwithsxh.local',
      extensions.crypt(init_pwd, extensions.gen_salt('bf')),
      now(), now(), now(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      '{"display_name":"宋星禾"}'::jsonb,
      '', '', '', '', ''
    );

    insert into auth.identities (
      id, user_id, provider_id, provider, identity_data,
      last_sign_in_at, created_at, updated_at
    ) values (
      gen_random_uuid(), uid_song, 'songxinghe@whwithsxh.local', 'email',
      jsonb_build_object('sub', uid_song::text, 'email', 'songxinghe@whwithsxh.local', 'email_verified', true),
      now(), now(), now()
    );
  end if;
end $$;


-- ============================================================
-- 第 10 节：执行后的自检查询
-- ============================================================
-- 表是否存在 + RLS 是否开启（两条都应为 true）
select tablename, rowsecurity as rls_enabled
from pg_tables
where schemaname = 'public' and tablename in ('letters', 'timeline');

-- 策略清单（应为 8 条，roles 均为 {authenticated}）
select tablename, policyname, cmd, roles::text
from pg_policies
where schemaname = 'public' and tablename in ('letters', 'timeline')
order by tablename, policyname;

-- 账号是否创建成功
select id, email, email_confirmed_at is not null as confirmed
from auth.users order by email;
