# 音效文件说明

## 📁 需要的音效文件

请将以下音效文件放置在此目录中：

### 1. start_work.mp3
- **用途**: 开始工作时播放
- **建议**: 机械启动声、打字声、或激励性的短音效
- **时长**: 1-2 秒
- **音量**: 中等

### 2. level_up.mp3
- **用途**: 冒险者升级时播放
- **建议**: 清脆的铃声、胜利号角、或欢快的音效
- **时长**: 2-3 秒
- **音量**: 较响

### 3. project_complete.mp3
- **用途**: 项目（BOSS）完成时播放
- **建议**: 胜利号角、成就解锁音效
- **时长**: 3-5 秒
- **音量**: 较响

### 4. achievement.mp3
- **用途**: 解锁成就时播放
- **建议**: 清脆的提示音、星星闪烁音效
- **时长**: 1-2 秒
- **音量**: 中等

### 5. purchase.mp3
- **用途**: 在商店购买物品时播放
- **建议**: 金币音效、收银机音效
- **时长**: 1-2 秒
- **音量**: 中等

### 6. error.mp3
- **用途**: 操作失败或错误时播放
- **建议**: 柔和的错误提示音（不要太刺耳）
- **时长**: 0.5-1 秒
- **音量**: 较轻

---

## 🎵 音效资源推荐

### 免费音效网站
1. **Freesound.org** - https://freesound.org/
   - 大量免费音效，需注册
   - 支持 CC 协议

2. **Zapsplat** - https://www.zapsplat.com/
   - 免费音效库
   - 需注册

3. **Mixkit** - https://mixkit.co/free-sound-effects/
   - 完全免费，无需注册
   - 可商用

4. **Pixabay** - https://pixabay.com/sound-effects/
   - 免费音效
   - 可商用

### 搜索关键词
- start_work: "keyboard typing", "machine start", "power on"
- level_up: "level up", "achievement", "success"
- project_complete: "victory", "fanfare", "quest complete"
- achievement: "notification", "ding", "sparkle"
- purchase: "coin", "cash register", "purchase"
- error: "error", "wrong", "negative"

---

## 🔧 临时方案

如果暂时没有音效文件，应用会：
1. 静默运行（不播放音效）
2. 在日志中记录音效播放请求
3. 不会崩溃或报错

用户可以在设置中关闭音效功能。

---

## 📝 添加音效后

1. 将音效文件复制到此目录
2. 确保文件名完全匹配（区分大小写）
3. 运行 `flutter clean` 清理缓存
4. 重新构建应用

---

## ⚖️ 版权说明

请确保使用的音效文件：
- 拥有合法使用权
- 符合开源项目的许可证要求
- 如果是 CC 协议，请在应用中添加相应的版权声明

---

**创建日期**: 2026-02-26  
**维护者**: 开发团队
