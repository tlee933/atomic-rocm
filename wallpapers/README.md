# Atomic-ROCm Wallpapers

**Theme:** Blue/Cyan/Purple gradients with glassy, modern aesthetic

## Color Palette

- **Electric Blue:** #1E88E5 (ROCm blue)
- **Cyber Cyan:** #00BCD4 (Compute accent)
- **Indie Purple:** #7C4DFF (GPU purple)
- **Deep Dark:** #1A1A1A (Background base)

## Wallpaper Requirements

- **Resolution:** 4K (3840x2160) minimum
- **Style:** Dark with vibrant blue/cyan/purple accents
- **Effect:** Gradients, bokeh, particles, or abstract geometric

## Recommended Sources

### 1. Generate with AI
```bash
# Use DALL-E, Midjourney, or Stable Diffusion
# Prompt: "Dark blue to cyan gradient wallpaper, 4K, abstract particles,
#          modern tech aesthetic, glassy effect, purple accents"
```

### 2. Unsplash/Pexels
Search for:
- "blue purple gradient 4k"
- "cyan abstract wallpaper"
- "dark tech wallpaper"
- "neon blue particles"

### 3. Manual Creation (GIMP/Inkscape)
- Create gradient from #1A1A1A → #1E88E5 → #00BCD4 → #7C4DFF
- Add blur/particles layer
- Export as 3840x2160 JPG

## Required Files

Place these wallpapers in this directory:

- `atomic-rocm-blue.jpg` - Primary (blue→cyan gradient)
- `atomic-rocm-purple.jpg` - Alternative (purple→blue)
- `atomic-rocm-cyber.jpg` - Alternative (cyan particles)

## Placeholder

For now, you can use solid color or simple gradients:

```bash
# Create simple gradient with ImageMagick
convert -size 3840x2160 gradient:'#1A1A1A-#1E88E5' atomic-rocm-blue.jpg
convert -size 3840x2160 gradient:'#1A1A1A-#7C4DFF' atomic-rocm-purple.jpg
convert -size 3840x2160 gradient:'#1A1A1A-#00BCD4' atomic-rocm-cyber.jpg
```

## License

If using third-party wallpapers, ensure they're CC0/Public Domain or properly licensed!
