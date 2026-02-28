# 🎬 精灵动画实现指南

**创建时间**: 2026-02-28  
**状态**: 技术方案已准备，待实现  
**难度**: 中等

---

## 📋 当前状态

### 已完成
- ✅ 创建了 `SpriteAnimationControl.cs` - 自定义动画控件
- ✅ 创建了 `SpriteHelper.cs` - 帧路径辅助类
- ✅ 添加了所有勇者 Idle 和 Attack 帧到项目资源
- ✅ 在 ViewModel 中准备了帧路径数组

### 遇到的问题
- ❌ DataTemplate 中不支持数组类型的绑定
- ❌ DataTemplate 中不支持 MarkupExtension

### 当前方案
- 使用静态 PNG 图片（第一帧）
- 保持应用稳定运行
- 后续可以添加动画

---

## 🎯 三种动画实现方案

### 方案 A: 移出 DataTemplate（推荐）

将动画控件移到 DataTemplate 外面，直接在主 Grid 中使用。

**优点**:
- 可以直接绑定数组
- 代码简单
- 性能好

**缺点**:
- 需要重构 XAML 布局
- 皮肤切换需要手动管理

**实现步骤**:
1. 移除 DataTemplate
2. 直接在 Border 中创建两个 Grid（Boss 和 Cat 模式）
3. 使用 Visibility 绑定切换显示
4. 动画控件可以直接绑定 ViewModel 的帧数组

---

### 方案 B: 使用 Attached Property

创建一个 Attached Property 来设置帧路径。

**代码示例**:
```csharp
public static class SpriteAnimationHelper
{
    public static readonly DependencyProperty AnimationTypeProperty =
        DependencyProperty.RegisterAttached(
            "AnimationType",
            typeof(string),
            typeof(SpriteAnimationHelper),
            new PropertyMetadata(null, OnAnimationTypeChanged));

    public static void SetAnimationType(DependencyObject obj, string value)
    {
        obj.SetValue(AnimationTypeProperty, value);
    }

    public static string GetAnimationType(DependencyObject obj)
    {
        return (string)obj.GetValue(AnimationTypeProperty);
    }

    private static void OnAnimationTypeChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
    {
        if (d is SpriteAnimationControl control && e.NewValue is string type)
        {
            control.FramePaths = type switch
            {
                "HeroIdle" => SpriteHelper.GetHeroIdleFrames(),
                "HeroAttack" => SpriteHelper.GetHeroAttackFrames(),
                _ => Array.Empty<string>()
            };
        }
    }
}
```

**XAML 使用**:
```xml
<controls:SpriteAnimationControl 
    Width="32" Height="32"
    local:SpriteAnimationHelper.AnimationType="HeroIdle"
    FrameInterval="100"
    AutoPlay="True"/>
```

---

### 方案 C: 使用 Behavior

使用 Microsoft.Xaml.Behaviors 库创建行为。

**安装包**:
```bash
dotnet add package Microsoft.Xaml.Behaviors.Wpf
```

**代码示例**:
```csharp
public class SpriteAnimationBehavior : Behavior<SpriteAnimationControl>
{
    public string AnimationType { get; set; } = "HeroIdle";

    protected override void OnAttached()
    {
        base.OnAttached();
        AssociatedObject.FramePaths = AnimationType switch
        {
            "HeroIdle" => SpriteHelper.GetHeroIdleFrames(),
            "HeroAttack" => SpriteHelper.GetHeroAttackFrames(),
            _ => Array.Empty<string>()
        };
    }
}
```

**XAML 使用**:
```xml
<controls:SpriteAnimationControl Width="32" Height="32">
    <i:Interaction.Behaviors>
        <local:SpriteAnimationBehavior AnimationType="HeroIdle"/>
    </i:Interaction.Behaviors>
</controls:SpriteAnimationControl>
```

---

## 🚀 推荐实现步骤

### 第一步: 使用方案 A（最简单）

1. **重构 XAML 布局**
   - 移除 DataTemplate
   - 创建两个 Grid（BossBattleGrid 和 RunnerCatGrid）
   - 使用 Visibility 绑定切换

2. **添加动画控件**
   ```xml
   <Grid x:Name="BossBattleGrid" 
         Visibility="{Binding CurrentSkin, Converter={StaticResource SkinToVisibilityConverter}, ConverterParameter=boss_battle}">
       <controls:SpriteAnimationControl 
           FramePaths="{Binding HeroIdleFrames}"
           Width="32" Height="32"
           FrameInterval="100"
           AutoPlay="True"/>
   </Grid>
   ```

3. **创建 Visibility Converter**
   ```csharp
   public class SkinToVisibilityConverter : IValueConverter
   {
       public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
       {
           return value?.ToString() == parameter?.ToString() 
               ? Visibility.Visible 
               : Visibility.Collapsed;
       }
   }
   ```

---

## 📝 完整实现示例

### WidgetWindow.xaml（简化版）
```xml
<Border>
    <!-- Boss Battle Mode -->
    <Grid x:Name="BossBattleGrid" 
          Visibility="{Binding CurrentSkin, Converter={StaticResource SkinToVisibilityConverter}, ConverterParameter=boss_battle}">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <!-- Hero -->
        <StackPanel Grid.Row="0" Orientation="Horizontal">
            <controls:SpriteAnimationControl 
                FramePaths="{Binding HeroIdleFrames}"
                Width="32" Height="32"
                FrameInterval="100"
                AutoPlay="True"/>
            <TextBlock Text="勇者"/>
        </StackPanel>
        
        <!-- Boss HP Bar -->
        <Border Grid.Row="1" Background="#FFFF4757"/>
        
        <!-- Timer -->
        <TextBlock Grid.Row="2" Text="{Binding TimerText}"/>
        
        <!-- Resources -->
        <StackPanel Grid.Row="3" Orientation="Horizontal">
            <controls:SpriteAnimationControl 
                FramePaths="{Binding CoinFrames}"
                Width="20" Height="20"
                FrameInterval="100"
                AutoPlay="True"/>
            <TextBlock Text="{Binding GoldEarned}"/>
        </StackPanel>
    </Grid>
    
    <!-- Runner Cat Mode -->
    <Grid x:Name="RunnerCatGrid"
          Visibility="{Binding CurrentSkin, Converter={StaticResource SkinToVisibilityConverter}, ConverterParameter=runner_cat}">
        <!-- Similar structure -->
    </Grid>
</Border>
```

---

## 🎨 动画效果配置

### 帧间隔建议
- 待机动画: 100-150ms（慢速）
- 奔跑动画: 80-100ms（中速）
- 攻击动画: 60-80ms（快速）
- 金币旋转: 100ms（中速）

### 性能优化
1. **图片预加载**: 在 LoadFrames() 中使用 `bitmap.Freeze()`
2. **缓存策略**: 使用 `BitmapCacheOption.OnLoad`
3. **定时器优化**: 使用 DispatcherTimer 而不是 Thread.Sleep
4. **内存管理**: 及时释放不用的帧

---

## 🐛 常见问题

### 问题 1: 动画卡顿
**原因**: 帧间隔太短或图片太大  
**解决**: 增加帧间隔或优化图片尺寸

### 问题 2: 内存占用高
**原因**: 加载了太多帧  
**解决**: 减少帧数或使用更小的图片

### 问题 3: 动画不播放
**原因**: AutoPlay=False 或帧路径错误  
**解决**: 检查 AutoPlay 属性和帧路径

---

## 📊 性能对比

### 静态图片
- CPU: < 0.1%
- 内存: ~5 MB
- 加载: 即时

### 帧动画（8帧）
- CPU: 0.5-1%
- 内存: ~10-15 MB
- 加载: 100-200ms

### GIF 动画
- CPU: 1-2%
- 内存: ~15-20 MB
- 加载: 200-300ms
- 兼容性: 可能崩溃

---

## ✅ 下一步行动

### 立即可做
1. 保持当前的静态图片方案
2. 应用稳定运行
3. 继续开发其他功能

### 后续优化
1. 实现方案 A（移出 DataTemplate）
2. 添加帧动画
3. 优化性能

### 可选增强
1. 根据工作状态切换动画（Idle -> Run -> Attack）
2. 添加过渡动画
3. 添加音效配合

---

**创建时间**: 2026-02-28  
**维护者**: Kiro AI Assistant  
**状态**: 技术方案已准备

---

**当前方案已经很好了！静态图片简单可靠，后续可以随时添加动画。** 🎨

