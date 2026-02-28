using System.Linq;

namespace WorkHoursTimer.Helpers
{
    /// <summary>
    /// 精灵动画辅助类
    /// </summary>
    public static class SpriteHelper
    {
        /// <summary>
        /// 生成勇者待机动画帧路径
        /// </summary>
        public static string[] GetHeroIdleFrames()
        {
            return Enumerable.Range(0, 8)
                .Select(i => $"/Assets/Images/Hero/Hero Knight/Sprites/HeroKnight/Idle/HeroKnight_Idle_{i}.png")
                .ToArray();
        }

        /// <summary>
        /// 生成勇者攻击动画帧路径
        /// </summary>
        public static string[] GetHeroAttackFrames()
        {
            return Enumerable.Range(0, 6)
                .Select(i => $"/Assets/Images/Hero/Hero Knight/Sprites/HeroKnight/Attack1/HeroKnight_Attack1_{i}.png")
                .ToArray();
        }

        /// <summary>
        /// 生成勇者奔跑动画帧路径
        /// </summary>
        public static string[] GetHeroRunFrames()
        {
            return Enumerable.Range(0, 10)
                .Select(i => $"/Assets/Images/Hero/Hero Knight/Sprites/HeroKnight/Run/HeroKnight_Run_{i}.png")
                .ToArray();
        }

        /// <summary>
        /// 生成金币动画帧路径（从精灵图中提取）
        /// 注意：这里使用单个图片，实际应该是序列帧
        /// </summary>
        public static string[] GetCoinFrames()
        {
            // 暂时使用单帧
            return new[] { "/Assets/Images/Effects/SpinningCoin/Spinning Coin.png" };
        }

        /// <summary>
        /// 生成 Boss 待机动画帧路径
        /// 注意：Slime Sprites.png 是精灵图，需要手动分割
        /// </summary>
        public static string[] GetBossIdleFrames()
        {
            // 暂时使用单帧
            return new[] { "/Assets/Images/Boss/Animated Slime Enemy/Slime Sprites.png" };
        }

        /// <summary>
        /// 生成猫咪动画帧路径
        /// 注意：Tile.png 是精灵图，需要手动分割
        /// </summary>
        public static string[] GetCatFrames()
        {
            // 暂时使用单帧
            return new[] { "/Assets/Images/Cat/Tile32x32_2/Tile.png" };
        }
    }
}
