import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  final bool isGameMode;

  AppSettings({
    this.isGameMode = false,
  });

  AppSettings copyWith({
    bool? isGameMode,
  }) {
    return AppSettings(
      isGameMode: isGameMode ?? this.isGameMode,
    );
  }
}
