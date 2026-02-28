#!/usr/bin/env python3
"""
史莱姆跳跃动画切割工具
将 Slime Enemy 的 Jump 精灵图集切割成单独的帧
"""

from PIL import Image
import os

# Jump 动画配置（使用绿色史莱姆）
JUMP_CONFIGS = {
    "Jump_Start": {
        "file": "Slime Enemy/Jump/Sprite Sheet - Green Jump Start-up.png",
        "frames": None,  # 自动检测
        "frame_width": 96,
        "frame_height": 32,
        "output_dir": "Slime Enemy/Jump/Frames/Start"
    },
    "Jump_Up": {
        "file": "Slime Enemy/Jump/Sprite Sheet - Green Jump Up.png",
        "frames": None,
        "frame_width": 96,
        "frame_height": 32,
        "output_dir": "Slime Enemy/Jump/Frames/Up"
    },
    "Jump_ToFall": {
        "file": "Slime Enemy/Jump/Sprite Sheet - Green Jump to Fall.png",
        "frames": None,
        "frame_width": 96,
        "frame_height": 32,
        "output_dir": "Slime Enemy/Jump/Frames/ToFall"
    },
    "Jump_Down": {
        "file": "Slime Enemy/Jump/Sprite Sheet - Green Jump Down.png",
        "frames": None,
        "frame_width": 96,
        "frame_height": 32,
        "output_dir": "Slime Enemy/Jump/Frames/Down"
    },
    "Jump_Land": {
        "file": "Slime Enemy/Jump/Sprite Sheet - Green Jump Land.png",
        "frames": None,
        "frame_width": 96,
        "frame_height": 32,
        "output_dir": "Slime Enemy/Jump/Frames/Land"
    }
}

def split_sprite_sheet(config_name, config):
    """切割精灵图集"""
    print(f"\n处理 {config_name}...")
    
    # 读取精灵图集
    sprite_sheet_path = config["file"]
    if not os.path.exists(sprite_sheet_path):
        print(f"  ❌ 文件不存在: {sprite_sheet_path}")
        return 0
    
    img = Image.open(sprite_sheet_path)
    print(f"  📷 图片尺寸: {img.size}")
    
    # 自动计算帧数
    frame_width = config["frame_width"]
    frame_height = config["frame_height"]
    frames = config["frames"]
    
    if frames is None:
        # 根据图片宽度自动计算帧数
        frames = img.width // frame_width
        print(f"  🔍 自动检测到 {frames} 帧")
    
    # 创建输出目录
    output_dir = config["output_dir"]
    os.makedirs(output_dir, exist_ok=True)
    
    # 切割帧
    for i in range(frames):
        # 计算帧的位置（水平排列）
        left = i * frame_width
        top = 0
        right = left + frame_width
        bottom = frame_height
        
        # 裁剪帧
        frame = img.crop((left, top, right, bottom))
        
        # 保存帧
        output_path = os.path.join(output_dir, f"frame_{i}.png")
        frame.save(output_path)
        print(f"  ✅ 保存: {output_path}")
    
    print(f"  🎉 完成！共切割 {frames} 帧")
    return frames

def main():
    print("🎮 史莱姆跳跃动画切割工具")
    print("=" * 60)
    
    # 切换到脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    # 处理所有配置
    total_frames = 0
    frame_counts = {}
    
    for config_name, config in JUMP_CONFIGS.items():
        frames = split_sprite_sheet(config_name, config)
        total_frames += frames
        frame_counts[config_name] = frames
    
    print("\n" + "=" * 60)
    print("✅ 所有跳跃动画切割完成！")
    print("\n📊 帧数统计:")
    for name, count in frame_counts.items():
        print(f"  - {name}: {count} 帧")
    print(f"  - 总计: {total_frames} 帧")
    
    print("\n💡 动画使用建议:")
    print("  1. 完整跳跃: Start → Up → ToFall → Down → Land")
    print("  2. 简单跳跃: Start → Up → Land")
    print("  3. 弹跳效果: Up → Down (循环)")
    
    print("\n📝 下一步:")
    print("  1. 查看切割后的帧: Slime Enemy/Jump/Frames/")
    print("  2. 选择要使用的跳跃阶段")
    print("  3. 将帧添加到 WorkHoursTimer.csproj")
    print("  4. 更新 WidgetViewModel.cs")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()
