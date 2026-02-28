import 'package:audioplayers/audioplayers.dart';

/// 音效服务
/// 负责管理应用中的所有音效播放
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;
  double _volume = 0.5; // 默认音量 50%

  /// 音效类型枚举
  static const String startWork = 'start_work';
  static const String levelUp = 'level_up';
  static const String projectComplete = 'project_complete';
  static const String achievement = 'achievement';
  static const String purchase = 'purchase';
  static const String error = 'error';

  /// 音效文件映射
  /// 注意：路径不包含 'assets/' 前缀，因为 AssetSource 会自动添加
  static const Map<String, String> _soundFiles = {
    startWork: 'audio/start_work.mp3',
    levelUp: 'audio/level_up.mp3',
    projectComplete: 'audio/project_complete.mp3',
    achievement: 'audio/achievement.mp3',
    purchase: 'audio/purchase.mp3',
    error: 'audio/error.mp3',
  };

  /// 初始化音效服务
  Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(_volume);
  }

  /// 播放音效
  /// [soundType] 音效类型
  Future<void> play(String soundType) async {
    if (_isMuted) return;

    final soundFile = _soundFiles[soundType];
    if (soundFile == null) {
      print('警告：未找到音效文件：$soundType');
      return;
    }

    try {
      // 使用 AssetSource 播放本地资源
      // 注意：需要在 pubspec.yaml 中配置 assets
      await _player.play(AssetSource(soundFile));
    } catch (e) {
      print('播放音效失败：$soundType, 错误：$e');
    }
  }

  /// 停止当前播放
  Future<void> stop() async {
    await _player.stop();
  }

  /// 设置音量
  /// [volume] 音量值 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  /// 获取当前音量
  double get volume => _volume;

  /// 设置静音状态
  void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      stop();
    }
  }

  /// 获取静音状态
  bool get isMuted => _isMuted;

  /// 切换静音状态
  void toggleMute() {
    setMuted(!_isMuted);
  }

  /// 播放开始工作音效
  Future<void> playStartWork() => play(startWork);

  /// 播放升级音效
  Future<void> playLevelUp() => play(levelUp);

  /// 播放项目完成音效
  Future<void> playProjectComplete() => play(projectComplete);

  /// 播放成就解锁音效
  Future<void> playAchievement() => play(achievement);

  /// 播放购买音效
  Future<void> playPurchase() => play(purchase);

  /// 播放错误音效
  Future<void> playError() => play(error);

  /// 释放资源
  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// 音效管理器（简化版，用于快速调用）
class SoundManager {
  static final AudioService _audio = AudioService();

  /// 初始化
  static Future<void> init() => _audio.init();

  /// 播放音效
  static Future<void> play(String soundType) => _audio.play(soundType);

  /// 开始工作
  static Future<void> startWork() => _audio.playStartWork();

  /// 升级
  static Future<void> levelUp() => _audio.playLevelUp();

  /// 项目完成
  static Future<void> projectComplete() => _audio.playProjectComplete();

  /// 成就解锁
  static Future<void> achievement() => _audio.playAchievement();

  /// 购买
  static Future<void> purchase() => _audio.playPurchase();

  /// 错误
  static Future<void> error() => _audio.playError();

  /// 设置音量
  static Future<void> setVolume(double volume) => _audio.setVolume(volume);

  /// 获取音量
  static double get volume => _audio.volume;

  /// 设置静音
  static void setMuted(bool muted) => _audio.setMuted(muted);

  /// 获取静音状态
  static bool get isMuted => _audio.isMuted;

  /// 切换静音
  static void toggleMute() => _audio.toggleMute();
}
