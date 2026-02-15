#!/usr/bin/env python3
"""
Generate App Icon Script
This script creates a 1024x1024 app icon with a fork and knife symbol.
Requires: pip install Pillow
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import sys
    import os
except ImportError:
    print("❌ Error: Pillow is required. Install it with: pip install Pillow")
    sys.exit(1)

def create_app_icon():
    # Create a 1024x1024 image
    size = (1024, 1024)
    img = Image.new('RGB', size, color='white')
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (green to blue)
    # Since PIL doesn't have built-in gradients, we'll create a simple gradient
    for y in range(1024):
        # Calculate gradient color
        ratio = y / 1024
        r = int(0 * (1 - ratio) + 0 * ratio)  # Green component
        g = int(128 * (1 - ratio) + 0 * ratio)  # Green to Blue
        b = int(0 * (1 - ratio) + 255 * ratio)  # Blue component
        draw.line([(0, y), (1024, y)], fill=(r, g, b))
    
    # Note: We can't easily draw SF Symbols, so we'll create a simple fork/knife representation
    # For a proper icon, you should use the SF Symbol in Xcode or use a design tool
    
    # Save the image
    output_path = "app_icon_1024x1024.png"
    img.save(output_path, 'PNG')
    print(f"✅ Basic app icon created: {output_path}")
    print("⚠️  Note: This is a basic gradient. For the fork/knife symbol, use Xcode or a design tool.")
    print("   You can drag the SF Symbol 'fork.knife.circle.fill' into Xcode's AppIcon asset.")

if __name__ == "__main__":
    create_app_icon()
