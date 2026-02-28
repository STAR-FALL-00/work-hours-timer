#!/usr/bin/env python3
"""
精灵图集切割工具
将 Slime Enemy 的精灵图集切割成单独的帧
"""

from PIL import Image
import os

# 配置
SPRITE_CONFIGS = {
    "Idle": {
        "file": "Slime Enemy/Idle/Sprite Sheet - Green Idle.png",
        "frames": 7,
        "frame_width": 96,
        "frame_height": 32,
        "output_dir": "Slime Enemy/Idle/Frames"
    },
    "Hurt": {
        "file": "Slime Enemy/Hurt/Sprite Sheet - Green Hurt - No Flash.png",
        "frames": 11,
        "frame_width": 96,
        "frame_height": 32,
        "output_dir": "Slime Enemy/Hurt/Frames"
    },
    "Death": {
        "file": "Slime Enemy/Death/Sprite Sheet - Green Death - No Flash.png",
        "frames": 14,
        "frame_width": 96,
        "frame_height": 32,
        "output_dir": "Slime Enemy/Death/Frames"
    }
}

def split_sprite_sheet(config_name, config):
    """切割精灵图集"""
    print(f"\n处理 {config_name}...")
    
    # 读取精灵图集
    sprite_sheet_path = config["file"]
    if not os.path.exists(sprite_sheet_path):
        print(f"  ❌ 文件不存在: {sprite_sheet_path}")
        return
    
    img = Image.open(sprite_sheet_path)
    print(f"  📷 图片尺寸: {img.size}")
    
    # 创建输出目录
    output_dir = config["output_dir"]
    os.makedirs(output_dir, exist_ok=True)
    
    # 切割帧
    frame_width = config["frame_width"]
    frame_height = config["frame_height"]
    frames = config["frames"]
    
    for i in range(frames):
        # 计算帧的位置（假设是水平排列）
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

def main():
    print("🎮 Slime Enemy 精灵图集切割工具")
    print("=" * 50)
    
    # 切换到脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    # 处理所有配置
    for config_name, config in SPRITE_CONFIGS.items():
        split_sprite_sheet(config_name, config)
    
    print("\n" + "=" * 50)
    print("✅ 所有精灵图集切割完成！")
    print("\n下一步:")
    print("1. 将切割后的帧添加到 WorkHoursTimer.csproj")
    print("2. 更新 WidgetViewModel.cs 使用新的帧路径")
    print("3. 重新编译并测试")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()
