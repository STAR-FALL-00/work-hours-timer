# 🔧 工作时间设置调试指南

## 问题描述
点击"工作时间设置"按钮后应用退出

## 可能的原因

### 1. StaticResource 引用错误
**症状**: XAML 中引用了不存在的资源
**解决**: 已修复，将 `{StaticResource TextSecondary}` 和 `{StaticResource AccentGold}` 改为硬编码颜色值

### 2. 构造函数异常
**症状**: WorkTimeSettingsDialog 构造时抛出异常
**可能原因**:
- XAML 解析错误
- 控件初始化失败
- 事件处理器绑定失败

### 3. DataService 访问异常
**症状**: 访问 `DataService.Instance.AppData.Settings` 时出错
**可能原因**:
- Settings 对象为 null
- WorkStartHour 或 WorkEndHour 属性不存在

## 调试步骤

### 步骤 1: 检查编译
```bash
cd wpf_app/WorkHoursTimer
dotnet build
```
✅ 已通过 - 无编译错误

### 步骤 2: 运行测试脚本
```bash
cd wpf_app
./test-work-time-settings.bat
```

### 步骤 3: 查看控制台输出
应用崩溃时会显示：
- 异常类型
- 错误消息
- 堆栈跟踪

### 步骤 4: 检查 Visual Studio 输出窗口
如果使用 Visual Studio 调试：
1. 打开 WorkHoursTimer.sln
2. 按 F5 启动调试
3. 点击"工作时间设置"按钮
4. 查看"输出"窗口的调试信息

## 已实施的修复

### 修复 1: 移除 StaticResource 引用
```xml
<!-- 修改前 -->
<Border BorderBrush="{StaticResource TextSecondary}">
    <TextBlock Foreground="{StaticResource AccentGold}"/>
</Border>

<!-- 修改后 -->
<Border BorderBrush="#80808080">
    <TextBlock Foreground="#FFD700"/>
</Border>
```

### 修复 2: 添加异常处理
```csharp
private void WorkTimeSettings_Click(object sender, RoutedEventArgs e)
{
    try
    {
        var dialog = new WorkTimeSettingsDialog { Owner = this };
        // ...
    }
    catch (Exception ex)
    {
        System.Diagnostics.Debug.WriteLine($"❌ 错误: {ex.Message}");
        MessageBox.Show($"打开设置窗口失败:\n{ex.Message}");
    }
}
```

## 常见错误及解决方案

### 错误 1: XamlParseException
```
System.Windows.Markup.XamlParseException: 
'Provide value on 'System.Windows.StaticResourceExtension' threw an exception.'
```
**原因**: XAML 中引用了不存在的资源
**解决**: 使用硬编码颜色或 DynamicResource

### 错误 2: NullReferenceException
```
System.NullReferenceException: Object reference not set to an instance of an object.
at WorkHoursTimer.WorkTimeSettingsDialog.LoadSettings()
```
**原因**: Settings 对象为 null
**解决**: 确保 DataService 已初始化

### 错误 3: MissingMemberException
```
System.MissingMemberException: 
'WorkHoursTimer.Models.Settings' does not contain a definition for 'WorkStartHour'
```
**原因**: Settings 类缺少属性
**解决**: 确认 Settings.cs 已添加 WorkStartHour 和 WorkEndHour

## 验证清单

- [x] Settings.cs 已添加 WorkStartHour 和 WorkEndHour
- [x] WorkTimeSettingsDialog.xaml 无 XAML 语法错误
- [x] WorkTimeSettingsDialog.xaml.cs 编译通过
- [x] MainWindow.xaml 添加了按钮
- [x] MainWindow.xaml.cs 添加了事件处理
- [x] 移除了 StaticResource 引用
- [x] 添加了异常处理

## 下一步

如果问题仍然存在，请：

1. **运行测试脚本**
   ```bash
   cd wpf_app
   ./test-work-time-settings.bat
   ```

2. **查看错误信息**
   - 记录完整的异常消息
   - 记录堆栈跟踪
   - 截图错误对话框

3. **提供调试信息**
   - 异常类型
   - 错误消息
   - 发生位置（哪个文件、哪一行）

## 临时解决方案

如果设置对话框无法打开，可以手动编辑配置文件：

1. 找到配置文件：
   ```
   %APPDATA%\WorkHoursTimer\app_data.json
   ```

2. 编辑 settings 部分：
   ```json
   {
     "settings": {
       "workStartHour": 9,
       "workEndHour": 18,
       ...
     }
   }
   ```

3. 保存并重启应用

## 联系支持

如果以上方法都无法解决，请提供：
- 完整的错误消息
- 堆栈跟踪
- app_data.json 文件内容（隐藏敏感信息）
- Windows 版本和 .NET 版本
