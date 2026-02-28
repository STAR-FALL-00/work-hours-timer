# 📥 素材下载快速指南

**创建日期**: 2026-02-28  
**预计时间**: 15-30 分钟

---

## 🎯 目录已创建

素材文件夹已经创建好了：
```
wpf_app/WorkHoursTimer/Assets/Images/
├── Hero/       ← 勇者动画放这里
├── Boss/       ← Boss 动画放这里
├── Cat/        ← 猫咪动画放这里
├── UI/         ← UI 图标放这里
└── Effects/    ← 特效放这里（可选）
```

每个文件夹里都有 `README.txt` 说明文件。

---

## 📋 下载步骤

### Step 1: 下载猫咪素材 🐱

1. **访问**: https://seathing.itch.io/cat-sprite
2. **点击**: "Download" 按钮
3. **解压**: 下载的 ZIP 文件
4. **复制**: 找到以下 GIF 文件
   - `cat_idle.gif` → 复制到 `Cat/` 文件夹
   - `cat_run.gif` → 复制到 `Cat/` 文件夹
   - `cat_sleep.gif` → 复制到 `Cat/` 文件夹

---

### Step 2: 下载勇者素材 🗡️

1. **访问**: https://szadiart.itch.io/hero-knight
2. **点击**: "Download" 按钮
3. **解压**: 下载的 ZIP 文件
4. **找到**: `Sprites` 文件夹
5. **转换**: 如果是 PNG 序列帧，需要转换为 GIF
   - 访问: https://ezgif.com/maker
   - 上传所有 Idle 序列帧
   - 设置延迟: 100ms
   - 生成 GIF
   - 保存为 `hero_idle.gif`
   - 重复以上步骤处理 Attack 动画
6. **复制**: 
   - `hero_idle.gif` → 复制到 `Hero/` 文件夹
   - `hero_attack.gif` → 复制到 `Hero/` 文件夹

---

### Step 3: 下载 Boss 素材 👹

1. **访问**: https://pixelfrog-assets.itch.io/kings-and-pigs
2. **点击**: "Download" 按钮
3. **解压**: 下载的 ZIP 文件
4. **找到**: `Sprites/02-King Pig` 文件夹
5. **转换**: 将 PNG 序列帧转换为 GIF（同上）
6. **复制**:
   - `boss_idle.gif` → 复制到 `Boss/` 文件夹
   - `boss_hit.gif` → 复制到 `Boss/` 文件夹

---

### Step 4: 下载金币素材 💰

1. **访问**: https://lornn.itch.io/pixel-art-coin-4-colors
2. **点击**: "Download" 按钮
3. **解压**: 下载的 ZIP 文件
4. **选择**: 金色的金币 GIF
5. **复制**: 
   - 重命名为 `coin_spin.gif`
   - 复制到 `UI/` 文件夹

---

## ✅ 完成检查

下载完成后，你的文件夹应该是这样的：

```
Assets/Images/
├── Hero/
│   ├── hero_idle.gif ✅
│   ├── hero_attack.gif ✅
│   └── README.txt
├── Boss/
│   ├── boss_idle.gif ✅
│   ├── boss_hit.gif ✅
│   └── README.txt
├── Cat/
│   ├── cat_idle.gif ✅
│   ├── cat_run.gif ✅
│   ├── cat_sleep.gif ✅
│   └── README.txt
├── UI/
│   ├── coin_spin.gif ✅
│   └── README.txt
└── Effects/
    └── README.txt
```

---

## 🛠️ 如果遇到问题

### 问题 1: 下载的是 PNG 序列帧，不是 GIF
**解决方案**: 使用在线工具转换
1. 访问: https://ezgif.com/maker
2. 上传所有序列帧
3. 设置帧延迟: 100ms
4. 点击 "Make a GIF"
5. 下载生成的 GIF

### 问题 2: 找不到具体的文件
**解决方案**: 
- 查看下载包中的文件夹结构
- 通常在 `Sprites/` 或 `Assets/` 文件夹中
- 查看 README 或 LICENSE 文件获取说明

### 问题 3: 链接失效
**解决方案**: 
- 在 itch.io 上搜索素材名称
- 或使用备选素材
- 或告诉我，我提供其他链接

---

## 💡 快速替代方案

如果暂时无法下载，可以：

### 方案 A: 使用占位符
我可以创建使用 Emoji 的临时版本：
- 勇者: 🗡️
- Boss: 👹
- 猫咪: 🐱
- 金币: 💰

### 方案 B: 使用简单图形
我可以创建使用彩色方块的临时版本：
- 勇者: 蓝色方块
- Boss: 红色圆形
- 猫咪: 橙色椭圆

---

## 📞 完成后

下载完成后，请：

1. **检查文件**: 确认所有必需文件都在正确的文件夹
2. **通知我**: 说 "素材已下载完成"
3. **开始集成**: 我会立即开始编写代码集成这些素材

---

## 📊 预计效果

完成后，你的挂件窗口将会：
- ✨ 显示流畅的像素动画
- 🎮 根据工作状态自动切换动画
- 💎 保持清晰的像素风格
- 🌟 与主窗口完美搭配

---

**创建时间**: 2026-02-28  
**预计下载时间**: 15-30 分钟

---

**📥 开始下载吧！完成后告诉我！**
