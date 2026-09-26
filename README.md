# 王鸿 & 宋星禾 · 我们的小宇宙 💗

一个双人纪念 + 互动网页。倒计时、地图、约定是纯前端展示；留言板、信件、照片墙、小事记、愿望清单由 Supabase 提供数据存储与实时同步。

- **线上地址**：https://chrisbetheking.github.io/whwithsxh/
- **Supabase 项目**：whwithsxh（ref `pguzkbjhsnszeccprxdx`）
- **技术栈**：HTML5 + CSS3 + 原生 JavaScript（单文件） / Supabase（数据 + Realtime + Storage） / Leaflet + OpenStreetMap（地图） / GitHub Pages（部署）

---

## 目录结构

```
whwithsxh/
├── index.html    # 全部内容（内联 CSS 和 JS）
├── README.md     # 本文件
├── deploy.sh     # 一键推送脚本
└── _parts/       # 开发用分块源文件（本地保留，不入库）
```

---

## 页面结构（自上而下）

| # | 区块 | 数据来源 |
|---|---|---|
| ① | Hero 首屏（名字 + 打字机 + 在一起倒计时） | 本地 |
| ② | 📍 我们的距离（地图 + 直线距离） | 本地（Leaflet + OSM） |
| ③ | 🌙 未来小约定（随机抽一条） | 本地 |
| ④ | 💬 留言板 | Supabase `messages` + Realtime |
| ⑤ | 💌 私密信件 | Supabase `letters` |
| ⑥ | 📸 照片墙 | Supabase `photos` + Storage |
| ⑦ | 📅 我们的小事记 | Supabase `timeline`（断网降级本地） |
| ⑧ | ⭐ 愿望清单 | Supabase `wishlist` |
| ⑨ | 页脚 | 本地 |

---

## Supabase 配置区位置

在 `index.html` 的 JS 开头（搜索 `SUPABASE 配置区`），大概在文件第 1600 行附近：

```js
/* ⚙️ SUPABASE 配置区（要换项目 / 换 key，只改这两行） */
const SUPABASE_URL = 'https://pguzkbjhsnszeccprxdx.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_8yGJYAW0E9INtDFT9aK81g_RPuWJ8jJ';
```

**⚠️ 只能用 anon / publishable key**，绝对不要用 service_role key —— 网页是公开的，放进去等于把数据库管理权限公开。

**去哪里找**：Supabase 控制台 → 项目 → Settings → API。

---

## 数据库结构

五张表，全部启用 RLS，策略为「anon + authenticated 可读写」（私密网站不做登录，靠网址保密）。

### `messages` 留言板

| 字段 | 类型 | 约束 |
|---|---|---|
| id | uuid | 主键 |
| created_at | timestamptz | 默认 now() |
| author | text | `王鸿` 或 `宋星禾` |
| content | text | 最长 500 字 |
| mood | text | happy/love/miss/sad/neutral |

### `letters` 私密信件

| 字段 | 类型 | 约束 |
|---|---|---|
| id | uuid | 主键 |
| created_at | timestamptz | 默认 now() |
| author | text | `王鸿` 或 `宋星禾` |
| title | text | 最长 100 字 |
| content | text | 最长 5000 字 |
| is_read | boolean | 默认 false |
| read_at | timestamptz | 打开时写入 |

### `photos` 照片墙

| 字段 | 类型 | 约束 |
|---|---|---|
| id | uuid | 主键 |
| created_at | timestamptz | 默认 now() |
| uploader | text | `王鸿` 或 `宋星禾` |
| caption | text | 最长 200 字 |
| storage_path | text | Storage 里的文件路径 |
| taken_at | date | 拍摄日期（可空） |

图片文件存在 Storage 的 **photos** bucket（public，单文件上限 10MB）。

### `timeline` 我们的小事记

| 字段 | 类型 | 约束 |
|---|---|---|
| id | uuid | 主键 |
| created_at | timestamptz | 默认 now() |
| event_date | date | 事件日期 |
| title | text | 最长 100 字 |
| description | text | 最长 500 字 |
| emoji | text | 默认 💗 |

### `wishlist` 愿望清单

| 字段 | 类型 | 约束 |
|---|---|---|
| id | uuid | 主键 |
| created_at | timestamptz | 默认 now() |
| title | text | 最长 200 字 |
| category | text | travel/food/movie/experience/other |
| is_done | boolean | 默认 false |
| done_at | timestamptz | 完成时写入 |
| created_by | text | `王鸿` 或 `宋星禾` |

---

## 怎么修改每条数据

**方式一：直接在网页上操作（推荐）**

| 数据 | 怎么改 |
|---|---|
| 留言 | 底部输入框写内容 → 选作者和表情 → 点「发送」；点每条右上角 ✕ 删除 |
| 信件 | 点「+ 写新信件」→ 选作者、填标题正文 → 保存；点标题条展开阅读（自动标记已读）；展开后底部「删除」 |
| 照片 | 点「+ 上传照片」→ 选图 → 填配文和日期 → 点「上传」；点图放大看；右上角 ✕ 删除 |
| 小事记 | 点「+ 添加事件」→ 选日期、填标题、选图标 → 保存；每条右侧 ✕ 删除 |
| 愿望 | 点「+ 添加愿望」→ 填内容、选分类 → 保存；点左侧方框打勾标记完成；✕ 删除 |

**方式二：Supabase 控制台**

Table Editor → 选表 → 直接编辑行（改文字、改作者名等）。

**方式三：改页面固定文案（写死的部分）**

在 `index.html` 里搜索：

| 想改什么 | 搜索 |
|---|---|
| 在一起的日期 | `TOGETHER_DATE` |
| 城市坐标 | `PEOPLE` |
| 随机约定文案 | `PROMISES` |
| 打字机句子 | `HERO_TEXTS` |
| 小事记离线兜底数据 | `TIMELINE_FALLBACK` |
| Supabase 地址/密钥 | `SUPABASE 配置区` |

---

## 断网降级逻辑

| 区块 | 断网时表现 |
|---|---|
| 小事记 | ✅ **显示本地兜底数据**（`TIMELINE_FALLBACK`），每条右上角标注「离线数据」，隐藏删除按钮 |
| 留言板 / 信件 / 照片墙 / 愿望清单 | ⚠️ 显示「加载失败 + 重试按钮」，点重试可重新拉取 |
| 倒计时 / 打字机 / 约定 / 地图（已缓存） | ✅ 不受影响，照常工作 |
| Supabase SDK 未加载 | ⚠️ 四个云端区块显示「云端组件没加载出来」，小事记仍用本地数据 |

所有请求都有 **8 秒超时**（上传 60 秒），网络卡住时快速失败而不是一直转圈。

---

## 部署

```bash
cd whwithsxh
git add -A
git commit -m "更新"
./deploy.sh
```

等 1-2 分钟，访问 https://chrisbetheking.github.io/whwithsxh/ 即可。

Pages 配置（已完成）：Settings → Pages → Source `Deploy from a branch` → Branch `main` → `/ (root)`。

---

## 常见问题

**Q：为什么不用登录，谁打开都能改？**
按需求设计成"私密网站不做登录"，靠网址保密。**风险**：知道网址的人可以读写所有内容（数据库 RLS 策略是"允许所有人读写"）。如果以后需要真正的隐私，需要加认证。

**Q：照片上传失败？**
检查：① 图片格式（支持 JPG/PNG/WebP/GIF/HEIC）② 大小不超过 10MB ③ 网络正常。

**Q：留言的"实时"是怎么实现的？**
用 Supabase Realtime 订阅 `messages` 表的 INSERT 事件。两台设备同时打开页面时，一方发送，另一方无需刷新即可看到（已实测验证）。

**Q：地图上的距离准吗？**
是两点之间的球面直线距离（Haversine 公式），成都到自贡约 153 公里。实际乘车里程会更长。

**Q：手机能用吗？**
可以，已做移动端适配：照片墙 2 列、输入框 16px 防缩放、对话框从底部滑出、无横向滚动。

---

## 隐私提醒 ⚠️

- 本站**无登录、无加密**，任何拿到网址的人都能查看和修改内容。
- 数据库策略是"允许所有人读写"，所以**不要放**身份证号、住址、银行卡等敏感信息。
- 照片存在 public bucket 里，拿到 URL 的人可以直接访问图片。
- 如果以后需要真隐私：加 Supabase Auth 登录 + 收紧 RLS 策略（只允许特定用户读写）。
