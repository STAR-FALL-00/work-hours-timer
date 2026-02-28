using System;
using System.Linq;
using System.Windows.Markup;

namespace WorkHoursTimer.Helpers
{
    /// <summary>
    /// XAML 标记扩展 - 用于生成帧路径数组
    /// </summary>
    public class FramePathsExtension : MarkupExtension
    {
        public string Type { get; set; } = "HeroIdle";

        public override object ProvideValue(IServiceProvider serviceProvider)
        {
            return Type switch
            {
                "HeroIdle" => SpriteHelper.GetHeroIdleFrames(),
                "HeroAttack" => SpriteHelper.GetHeroAttackFrames(),
                "HeroRun" => SpriteHelper.GetHeroRunFrames(),
                "Coin" => SpriteHelper.GetCoinFrames(),
                "BossIdle" => SpriteHelper.GetBossIdleFrames(),
                "Cat" => SpriteHelper.GetCatFrames(),
                _ => Array.Empty<string>()
            };
        }
    }
}
