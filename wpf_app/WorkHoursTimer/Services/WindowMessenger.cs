using System;

namespace WorkHoursTimer.Services
{
    /// <summary>
    /// 窗口间消息传递服务（事件总线模式）
    /// 用于主窗口和挂件窗口之间的双向通信
    /// </summary>
    public class WindowMessenger
    {
        private static WindowMessenger? _instance;
        
        /// <summary>
        /// 单例实例
        /// </summary>
        public static WindowMessenger Instance => _instance ??= new WindowMessenger();

        /// <summary>
        /// 消息接收事件
        /// </summary>
        public event EventHandler<MessageEventArgs>? MessageReceived;

        /// <summary>
        /// 私有构造函数（单例模式）
        /// </summary>
        private WindowMessenger()
        {
        }

        /// <summary>
        /// 发送消息
        /// </summary>
        /// <param name="type">消息类型</param>
        /// <param name="data">消息数据</param>
        public void SendMessage(string type, object? data = null)
        {
            MessageReceived?.Invoke(this, new MessageEventArgs
            {
                Type = type,
                Data = data,
                Timestamp = DateTime.Now
            });
        }
    }

    /// <summary>
    /// 消息事件参数
    /// </summary>
    public class MessageEventArgs : EventArgs
    {
        /// <summary>
        /// 消息类型
        /// </summary>
        public string Type { get; set; } = string.Empty;

        /// <summary>
        /// 消息数据
        /// </summary>
        public object? Data { get; set; }

        /// <summary>
        /// 消息时间戳
        /// </summary>
        public DateTime Timestamp { get; set; }
    }
}
