using System;
using WorkHoursTimer.Models;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 经济系统服务（金币、经验、等级）
    /// </summary>
    public class EconomyService
    {
        private static EconomyService? _instance;
        public static EconomyService Instance => _instance ??= new EconomyService();

        /// <summary>
        /// 冒险者档案
        /// </summary>
        public AdventurerProfile Profile { get; private set; }

        /// <summary>
        /// 等级提升事件
        /// </summary>
        public event EventHandler<LevelUpEventArgs>? LevelUp;

        /// <summary>
        /// 金币变化事件
        /// </summary>
        public event EventHandler<GoldChangedEventArgs>? GoldChanged;

        /// <summary>
        /// 经验值变化事件
        /// </summary>
        public event EventHandler<ExpChangedEventArgs>? ExpChanged;

        private EconomyService()
        {
            // 从数据服务加载档案
            Profile = DataService.Instance.AppData.AdventurerProfile ?? new AdventurerProfile();
        }

        /// <summary>
        /// 计算工作收益（金币和经验）
        /// </summary>
        public (int gold, int exp) CalculateRewards(int workSeconds)
        {
            // 基础计算：每小时100金币，50经验
            var hours = workSeconds / 3600.0;
            var gold = (int)(hours * 100);
            var exp = (int)(hours * 50);
            
            // 连续工作奖励（每连续一天+5%）
            var bonus = 1.0 + (Profile.ConsecutiveDays * 0.05);
            gold = (int)(gold * bonus);
            exp = (int)(exp * bonus);
            
            return (gold, exp);
        }

        /// <summary>
        /// 添加工作收益
        /// </summary>
        public void AddWorkRewards(int workSeconds)
        {
            var (gold, exp) = CalculateRewards(workSeconds);
            
            // 添加金币
            AddGold(gold);
            
            // 添加经验
            AddExperience(exp);
            
            // 更新总工作时长
            Profile.TotalWorkSeconds += workSeconds;
            
            // 更新连续工作天数
            Profile.UpdateConsecutiveDays();
            
            // 保存数据
            SaveProfile();
        }

        /// <summary>
        /// 添加金币
        /// </summary>
        public void AddGold(int amount)
        {
            var oldGold = Profile.Gold;
            Profile.AddGold(amount);
            
            GoldChanged?.Invoke(this, new GoldChangedEventArgs
            {
                OldValue = oldGold,
                NewValue = Profile.Gold,
                Change = amount
            });
            
            SaveProfile();
        }

        /// <summary>
        /// 扣除金币
        /// </summary>
        public bool SpendGold(int amount)
        {
            var oldGold = Profile.Gold;
            if (Profile.SpendGold(amount))
            {
                GoldChanged?.Invoke(this, new GoldChangedEventArgs
                {
                    OldValue = oldGold,
                    NewValue = Profile.Gold,
                    Change = -amount
                });
                
                SaveProfile();
                return true;
            }
            return false;
        }

        /// <summary>
        /// 添加经验值
        /// </summary>
        public void AddExperience(int exp)
        {
            var oldExp = Profile.Experience;
            var oldLevel = Profile.Level;
            
            var leveledUp = Profile.AddExperience(exp);
            
            ExpChanged?.Invoke(this, new ExpChangedEventArgs
            {
                OldValue = oldExp,
                NewValue = Profile.Experience,
                Change = exp
            });
            
            if (leveledUp)
            {
                LevelUp?.Invoke(this, new LevelUpEventArgs
                {
                    OldLevel = oldLevel,
                    NewLevel = Profile.Level
                });
            }
            
            SaveProfile();
        }

        /// <summary>
        /// 获取当前等级信息
        /// </summary>
        public (int level, int exp, int expToNext, double progress) GetLevelInfo()
        {
            var level = Profile.Level;
            var exp = Profile.Experience;
            var expToNext = Profile.ExperienceToNextLevel;
            var progress = (double)exp / expToNext * 100;
            
            return (level, exp, expToNext, progress);
        }

        /// <summary>
        /// 保存档案
        /// </summary>
        private void SaveProfile()
        {
            DataService.Instance.AppData.AdventurerProfile = Profile;
            DataService.Instance.SaveData();
        }
    }

    /// <summary>
    /// 等级提升事件参数
    /// </summary>
    public class LevelUpEventArgs : EventArgs
    {
        public int OldLevel { get; set; }
        public int NewLevel { get; set; }
    }

    /// <summary>
    /// 金币变化事件参数
    /// </summary>
    public class GoldChangedEventArgs : EventArgs
    {
        public int OldValue { get; set; }
        public int NewValue { get; set; }
        public int Change { get; set; }
    }

    /// <summary>
    /// 经验值变化事件参数
    /// </summary>
    public class ExpChangedEventArgs : EventArgs
    {
        public int OldValue { get; set; }
        public int NewValue { get; set; }
        public int Change { get; set; }
    }
}
