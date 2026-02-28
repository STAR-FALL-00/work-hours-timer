using System;
using System.IO;
using System.Text.Json;
using WorkHoursTimer.Models;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 数据持久化服务
    /// </summary>
    public class DataService
    {
        private static DataService? _instance;
        public static DataService Instance => _instance ??= new DataService();

        private readonly string _dataFilePath;
        private AppData _appData;

        /// <summary>
        /// 应用数据
        /// </summary>
        public AppData AppData => _appData;

        private DataService()
        {
            // 数据文件路径：AppData/Roaming/WorkHoursTimer/data.json
            var appDataFolder = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                "WorkHoursTimer"
            );

            if (!Directory.Exists(appDataFolder))
            {
                Directory.CreateDirectory(appDataFolder);
            }

            _dataFilePath = Path.Combine(appDataFolder, "data.json");
            _appData = LoadData();
        }

        /// <summary>
        /// 加载数据
        /// </summary>
        private AppData LoadData()
        {
            try
            {
                if (File.Exists(_dataFilePath))
                {
                    var json = File.ReadAllText(_dataFilePath);
                    return JsonSerializer.Deserialize<AppData>(json) ?? new AppData();
                }
            }
            catch (Exception ex)
            {
                // 记录错误（这里简化处理）
                System.Diagnostics.Debug.WriteLine($"加载数据失败: {ex.Message}");
            }

            return new AppData();
        }

        /// <summary>
        /// 保存数据
        /// </summary>
        public void SaveData()
        {
            try
            {
                var options = new JsonSerializerOptions
                {
                    WriteIndented = true
                };
                var json = JsonSerializer.Serialize(_appData, options);
                File.WriteAllText(_dataFilePath, json);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"保存数据失败: {ex.Message}");
            }
        }

        /// <summary>
        /// 添加工作会话
        /// </summary>
        public void AddSession(WorkSession session)
        {
            _appData.Sessions.Add(session);
            _appData.TotalWorkSeconds += session.DurationSeconds;
            SaveData();
        }

        /// <summary>
        /// 获取数据文件路径
        /// </summary>
        public string GetDataFilePath() => _dataFilePath;
    }
}
