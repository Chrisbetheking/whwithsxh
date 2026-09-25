# whwithsxh · 我们的私密空间 💗

王鸿 & 宋星禾的私密纪念网页。单页应用，手机优先，登录后可以写信、记录时间线、看两地距离、抽未来小约定。

- **线上地址**：https://chrisbetheking.github.io/whwithsxh/
- **技术栈**：HTML5 + CSS3 + 原生 JavaScript（单页，无框架） / Supabase（数据 + 登录） / Leaflet + OpenStreetMap（地图） / GitHub Pages（部署）

---

## 目录结构

```
whwithsxh/
├── index.html            # 完整单文件应用（内联 CSS 和 JS）
├── README.md             # 本文件
└── supabase/
    └── schema.sql        # 数据库结构完整备份（建表 / RLS / 触发器 / 账号）
```

---

## 一、部署到 GitHub Pages（完整步骤）

### 1. 创建仓库

在 GitHub 上新建一个仓库，名字必须是 `whwithsxh`（否则线上地址会不一样）。

- 建议设为 **Public**（GitHub Pages 免费版要求公开仓库，私有仓库需 GitHub Pro）。
- **不要**勾选 "Add a README"，保持空仓库即可。

### 2. 上传代码

**方式 A：网页上传（最简单，不用装任何工具）**

1. 打开新建好的仓库页面。
2. 点 **Add file → Upload files**。
3. 把 `index.html` 拖进去，提交（Commit changes）。
4. 再点 **Add file → Create new file**，文件名填 `supabase/schema.sql`，把内容粘进去提交。

**方式 B：命令行**

```bash
cd whwithsxh
git init
git add .
git commit -m "init: whwithsxh 我们的私密空间"
git branch -M main
git remote add origin git@github.com:你的用户名/whwithsxh.git
git push -u origin main
```

### 3. 开启 GitHub Pages

1. 进入仓库 → **Settings**（设置）。
2. 左侧菜单找到 **Pages**。
3. **Source** 选 `Deploy from a branch`。
4. **Branch** 选 `main`，目录选 `/ (root)`，点 **Save**。
5. 等待 1–2 分钟，刷新页面，顶部会出现绿色地址：
   `https://你的用户名.github.io/whwithsxh/`

### 4. 首次访问

用密码登录（初始密码见下方「四、账号与密码」）。建议在手机上打开一次，然后「添加到主屏幕」，用起来跟 App 一样。

---

## 二、Supabase 替换说明（换项目时才需要动）

`index.html` 顶部有一小块配置区，部署前请确认这几行：

```js
/* 第 112 行附近 */
const SUPABASE_URL = 'YOUR_SUPABASE_URL';                 // ← 换成你的项目 URL
const SUPABASE_PUBLISHABLE_KEY = 'YOUR_SUPABASE_PUBLISHABLE_KEY'; // ← 换成你的 publishable key
```

**去哪里找这两个值：**

| 值 | 位置 |
|---|---|
| `SUPABASE_URL` | Supabase 控制台 → 项目 → **Settings → API** → Project URL |
| `SUPABASE_PUBLISHABLE_KEY` | 同上页面 → **Project API keys** → 选 `publishable`（`sb_publishable_...` 开头） |

> ⚠️ **务必用 publishable key**，不要用 `service_role` / secret key。
> publishable key 本来就设计成可以出现在浏览器里，它是「项目身份证」，不是密码。
> 真正的隐私保护来自数据库的 RLS 策略（见下）。
> 如果把 service_role key 放进网页，等于把数据库管理员权限公开了，**任何人**都能读写全部数据。

**当前线上配置**（本项目已填好，无需再改）：

- URL：`https://pguzkbjhsnszeccprxdx.supabase.co`
- Key：`sb_publishable_...`（已内联在 index.html）

---

## 三、数据库结构

两张表，均由 `supabase/schema.sql` 定义。

### `letters`（信件）

| 字段 | 类型 | 说明 |
|---|---|---|
| id | uuid | 主键，自动生成 |
| author | text | `wanghong` 或 `songxinghe` |
| title | text | 标题 |
| content | text | 正文，可留空 |
| created_at | timestamptz | 创建时间，默认当前 |
| updated_at | timestamptz | 更新时间，由触发器自动维护 |
| is_published | boolean | false 表示草稿，默认 true |

### `timeline`（时间线）

| 字段 | 类型 | 说明 |
|---|---|---|
| id | uuid | 主键，自动生成 |
| date | date | 日期 |
| title | text | 标题 |
| description | text | 描述，可留空 |
| author | text | 记录人 |

### 安全模型（两层防护，这是隐私的关键）

1. **表级权限（GRANT/REVOKE）**
   把 `anon` 角色的权限**全部收回**。未登录用户连"表"都接触不到，请求会直接报 permission denied。

2. **行级安全（RLS）**
   两张表都启用 RLS，策略只放行 `auth.uid()` 命中**两个账号 UUID** 的请求。
   即使有人想办法注册了新账号拿到了 `authenticated` 角色，他也读不到任何一行、写不进任何数据。

**已验证的行为**（部署时实测）：

| 场景 | 结果 |
|---|---|
| 未登录（只有 publishable key）读取信件 | ❌ 拒绝（permission denied） |
| 未登录写入信件 | ❌ 拒绝 |
| 王鸿账号登录后读写 | ✅ 成功 |
| 宋星禾账号登录后读写 | ✅ 成功 |

> 🔧 **改过账号后必做**：策略里写死了两个 UUID。如果以后删号重建，UUID 会变，
> 需要执行 `select id, email from auth.users;` 查出新 UUID，替换 `schema.sql` 第 6 节里的常量并重新执行。

---

## 四、账号与密码

系统里有且仅有两个账号，**前端没有注册入口**：

| 账号 | 登录名（前端不显示，仅内部使用） | 初始密码 |
|---|---|---|
| 王鸿 | `wanghong@whwithsxh.local` | `whwithsxh0907` |
| 宋星禾 | `songxinghe@whwithsxh.local` | `whwithsxh0907` |

前端登录框**只有一个密码输入框**。输入密码后，页面会拿这个密码依次尝试两个账号，任一匹配即登录成功——所以两个人用同一个密码就能进，不需要选身份。

**⚠️ 请务必修改初始密码**（两个账号建议改成同一个只有你们知道的密码）：

方式一：Supabase 控制台 → **Authentication → Users** → 点用户 → **Reset password**。

方式二：让 AI 助手用 MCP 执行（把 `你的新密码` 换掉）：

```sql
update auth.users
set encrypted_password = extensions.crypt('你的新密码', extensions.gen_salt('bf')),
    updated_at = now()
where email in ('wanghong@whwithsxh.local', 'songxinghe@whwithsxh.local');
```

**登录有效期**：Session 存在浏览器 localStorage，**7 天**内免密自动登录；超过 7 天需重新输入密码。点「退出登录」可立即清除。

---

## 五、功能说明

| 模块 | 说明 |
|---|---|
| 主页 | 在一起天数大号计时（每秒刷新，精确到秒）+ 四个功能入口 |
| 信件 | 卡片列表（写信人 / 标题 / 日期 / 前 60 字预览）→ 点开详情（信纸排版，长信内部滚动）；可新增、编辑、删除 |
| 时间线 | 垂直时间线，按日期排序，记录值得记住的日子 |
| 地图 | Leaflet 标记成都、自贡，虚线相连，Haversine 公式实时算直线距离（不硬编码） |
| 约定 | 内置 15 条未来小约定，随机抽取，点「换一个」刷新 |

**关键位置**（改代码时参考）：

- 在一起日期：`index.html` 里 `const TOGETHER_DATE = new Date('2026-09-07T00:00:00+08:00');`
- 两人坐标：`const PEOPLE = { wanghong: {...成都}, songxinghe: {...自贡} };`
- 约定内容：`const PROMISES = [...]` 数组，随便加

---

## 六、数据备份提醒 ⚠️

**这很重要。** 数据库是线上托管的，一旦误删无法自己恢复。

### 手动导出（推荐每月做一次）

方式一：Supabase 控制台 → **Table Editor** → 选中表 → 右上角导出 CSV。
两张表都导一次，存到手机相册或网盘。

方式二：让 AI 助手帮忙导出（对话里说「导出 letters 表」即可）。

### 检查项

- [ ] 有没有免费额度的容量提醒（免费版 500MB 数据库，文字内容完全够用）
- [ ] 项目会不会因为长期不用被暂停（免费版 7 天无活动会暂停，暂停后数据还在，登录控制台点一下恢复即可）
- [ ] 建议给 Supabase 账号开启两步验证

### 如果误删了信

- 单封信删掉后无法找回（前端有二次确认）。
- 所以**导出频率建议跟着写信频率走**：写完一封重要的信，顺手导出一次。

---

## 七、常见问题

**Q：手机打开显示空白 / 一直转圈？**
检查网络。首次加载需要从 CDN 拉取 Supabase 和 Leaflet 两个库；如果网络被墙或很慢，可能会超时，刷新重试即可。

**Q：提示"密码不正确，再试一次"？**
密码区分大小写。确认用的是修改后的新密码。连续失败可到 Supabase 控制台重置。

**Q：登录后看不到信？**
确认数据库里 `is_published` 是 `true`。或者检查 Session 是否过期（超过 7 天）。

**Q：地图不显示？**
OpenStreetMap 瓦片在国内偶尔较慢，耐心等一下，或换个网络。

**Q：想换一对情侣用？**
改 `index.html` 里的 `PEOPLE`、`TOGETHER_DATE`、`LOGIN_EMAILS`，改 `schema.sql` 里的账号邮箱，重新执行数据库脚本即可。

---

## 八、隐私说明

- 登录密码**从不保存在网页代码里**，只存在 Supabase Auth 的加密哈希中。
- 网页里的 publishable key 是公开凭证，不含任何数据权限。
- 信件内容只有在**登录成功拿到 JWT 之后**才可能被读取，且受 RLS 限制只能被这两个账号读取。
- 但请注意：如果**在公共设备上登录后忘了退出**，别人打开网页会自动进入。用完记得点「退出登录」。
