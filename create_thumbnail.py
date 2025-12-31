#!/usr/bin/env python3
"""
Script to create a thumbnail image for Ai Learning Language project
Requirements: JPG/PNG/GIF, max 5MB, 3:2 ratio recommended
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_thumbnail():
    # Set dimensions for 3:2 ratio (common sizes: 1200x800, 1500x1000, 1800x1200)
    # Using 1500x1000 for good quality while keeping file size reasonable
    width = 1500
    height = 1000
    
    # Create image with gradient background
    img = Image.new('RGB', (width, height), color='#FFFFFF')
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (blue to purple gradient - modern tech look)
    for y in range(height):
        # Calculate gradient color (bright blue to deep purple)
        ratio = y / height
        r = int(33 + (128 - 33) * (1 - ratio))
        g = int(150 + (43 - 150) * (1 - ratio))
        b = int(243 + (131 - 243) * (1 - ratio))
        draw.rectangle([(0, y), (width, y + 1)], fill=(r, g, b))
    
    # Add decorative circles (simple white circles)
    for i in range(5):
        x = width * (0.2 + i * 0.15)
        y_pos = height * (0.3 + (i % 2) * 0.4)
        size = 120 + i * 15
        # Draw white outline circles
        draw.ellipse(
            [x - size/2, y_pos - size/2, x + size/2, y_pos + size/2],
            fill=None,
            outline='#FFFFFF',
            width=4
        )
    
    # Try to use a nice font, fallback to default if not available
    try:
        # Try different font sizes and styles
        title_font_size = 100
        subtitle_font_size = 45
        
        # For Windows, try common fonts
        try:
            title_font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", title_font_size)
        except:
            title_font = ImageFont.truetype("arial.ttf", title_font_size)
        subtitle_font = ImageFont.truetype("arial.ttf", subtitle_font_size)
    except:
        try:
            title_font = ImageFont.truetype("arialbd.ttf", 100)
            subtitle_font = ImageFont.truetype("arial.ttf", 50)
        except:
            # Fallback to default font
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
    
    # Main title
    title = "Ai Learning Language"
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_height = title_bbox[3] - title_bbox[1]
    title_x = (width - title_width) / 2
    title_y = height * 0.35
    
    # Draw title with subtle shadow effect (offset darker version)
    shadow_offset = 3
    draw.text((title_x + shadow_offset, title_y + shadow_offset), title, fill='#1a1a2e', font=title_font)
    draw.text((title_x, title_y), title, fill='#FFFFFF', font=title_font)
    
    # Subtitle
    subtitle = "AI-Powered Language Learning"
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (width - subtitle_width) / 2
    subtitle_y = title_y + title_height + 25
    
    # Draw subtitle with shadow
    draw.text((subtitle_x + 2, subtitle_y + 2), subtitle, fill='#1a1a2e', font=subtitle_font)
    draw.text((subtitle_x, subtitle_y), subtitle, fill='#FFFFFF', font=subtitle_font)
    
    # Add language badges at bottom
    languages = ["Japanese", "English", "Chinese", "Korean"]
    lang_y = height * 0.75
    lang_spacing = width / (len(languages) + 1)
    
    for i, lang in enumerate(languages):
        lang_x = lang_spacing * (i + 1)
        lang_bbox = draw.textbbox((0, 0), lang, font=subtitle_font)
        lang_width = lang_bbox[2] - lang_bbox[0]
        lang_x = lang_x - lang_width / 2
        
        # Background box for language (semi-transparent effect using light color)
        padding = 20
        box_height = subtitle_font_size + padding * 2
        # Draw rounded rectangle effect with white background
        draw.rectangle(
            [lang_x - padding, lang_y - padding, lang_x + lang_width + padding, lang_y + box_height - padding],
            fill='#FFFFFF',
            outline='#FFFFFF',
            width=2
        )
        # Add subtle shadow
        draw.rectangle(
            [lang_x - padding + 2, lang_y - padding + 2, lang_x + lang_width + padding + 2, lang_y + box_height - padding + 2],
            fill='#E0E0E0',
            outline=None
        )
        draw.rectangle(
            [lang_x - padding, lang_y - padding, lang_x + lang_width + padding, lang_y + box_height - padding],
            fill='#FFFFFF',
            outline='#2196F3',
            width=3
        )
        draw.text((lang_x, lang_y), lang, fill='#2196F3', font=subtitle_font)
    
    # Save as PNG first (highest quality)
    png_path = 'project_thumbnail.png'
    img.save(png_path, 'PNG', optimize=True)
    
    # Also save as JPG (smaller file size)
    jpg_path = 'project_thumbnail.jpg'
    # Convert to RGB if needed and save as JPEG
    if img.mode != 'RGB':
        img = img.convert('RGB')
    img.save(jpg_path, 'JPEG', quality=92, optimize=True)
    
    # Check file sizes
    png_size = os.path.getsize(png_path) / (1024 * 1024)  # MB
    jpg_size = os.path.getsize(jpg_path) / (1024 * 1024)  # MB
    
    print("Thumbnail created successfully!")
    print(f"PNG: {png_path} ({png_size:.2f} MB)")
    print(f"JPG: {jpg_path} ({jpg_size:.2f} MB)")
    print(f"Dimensions: {width}x{height} (3:2 ratio)")
    
    if png_size > 5:
        print("Warning: PNG file exceeds 5MB limit")
    if jpg_size > 5:
        print("Warning: JPG file exceeds 5MB limit")
    else:
        print("JPG file is under 5MB limit - recommended for upload")
    
    return png_path, jpg_path

if __name__ == '__main__':
    create_thumbnail()
