using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;

namespace WorkHoursTimer.Helpers
{
    /// <summary>
    /// Win32 API 辅助类，用于实现鼠标穿透等高级窗口功能
    /// </summary>
    public static class Win32Helper
    {
        [DllImport("user32.dll")]
        private static extern int GetWindowLong(IntPtr hwnd, int index);

        [DllImport("user32.dll")]
        private static extern int SetWindowLong(IntPtr hwnd, int index, int newStyle);

        private const int GWL_EXSTYLE = -20;
        private const int WS_EX_TRANSPARENT = 0x00000020;

        /// <summary>
        /// 设置窗口鼠标穿透
        /// </summary>
        /// <param name="window">目标窗口</param>
        /// <param name="enable">true=启用穿透，false=禁用穿透</param>
        public static void SetClickThrough(Window window, bool enable)
        {
            var hwnd = new WindowInteropHelper(window).Handle;
            if (hwnd == IntPtr.Zero)
            {
                return; // 窗口句柄无效
            }

            var extendedStyle = GetWindowLong(hwnd, GWL_EXSTYLE);

            if (enable)
            {
                // 添加 WS_EX_TRANSPARENT 样式（启用穿透）
                SetWindowLong(hwnd, GWL_EXSTYLE, extendedStyle | WS_EX_TRANSPARENT);
            }
            else
            {
                // 移除 WS_EX_TRANSPARENT 样式（禁用穿透）
                SetWindowLong(hwnd, GWL_EXSTYLE, extendedStyle & ~WS_EX_TRANSPARENT);
            }
        }
    }
}
