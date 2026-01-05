# Atomic-ROCm Theming & Wallpapers

**Color Scheme:** Dark with blue/cyan/purple accents (ROCm-inspired)

---

## 1. Custom Wallpapers

### Wallpaper Strategy

**Location in container:** `/usr/share/backgrounds/atomic-rocm/`

**Wallpaper themes to include:**
1. **Dark Blue/Cyan** - Primary ROCm branding
2. **Purple/Magenta** - GPU compute aesthetic
3. **Gradient Dark** - Blue → Cyan → Purple transitions
4. **Abstract ROCm** - Geometric patterns with AMD colors

### Implementation in Containerfile

```dockerfile
# Add custom wallpapers
COPY wallpapers/ /usr/share/backgrounds/atomic-rocm/

# Set default wallpaper (KDE Plasma 6)
RUN mkdir -p /etc/skel/.config && \
    kwriteconfig6 --file /etc/skel/.config/plasmarc --group Wallpaper --key Image "/usr/share/backgrounds/atomic-rocm/rocm-dark-blue.jpg"

# Alternative: GNOME (if using Bluefin base instead of Aurora)
# RUN mkdir -p /etc/dconf/db/local.d && \
#     echo "[org/gnome/desktop/background]" > /etc/dconf/db/local.d/01-wallpaper && \
#     echo "picture-uri='file:///usr/share/backgrounds/atomic-rocm/rocm-dark-blue.jpg'" >> /etc/dconf/db/local.d/01-wallpaper && \
#     dconf update
```

---

## 2. Papirus Icons (Colorful & Modern!)

### Why Papirus?
- **Most colorful icon set available** - Vibrant colors for every app
- **Modern flat design** - Looks great with transparent windows
- **Comprehensive coverage** - 10,000+ icons for apps, folders, file types
- **Dark theme optimized** - Papirus-Dark variant for dark Plasma
- **Active development** - Constantly updated with new apps

### Papirus Variants

**Papirus-Dark** (Recommended for Atomic-ROCm):
- Designed for dark themes
- Icons have lighter colors that pop against dark backgrounds
- Perfect with our blue/cyan/purple color scheme

**ePapirus-Dark** (Alternative):
- Same as Papirus-Dark but with colorful folder icons
- Folders use vibrant colors (blue, green, purple, etc.)

### Installation

```dockerfile
# Install Papirus icon theme
RUN rpm-ostree install papirus-icon-theme

# Set Papirus-Dark as default
RUN kwriteconfig6 --file /etc/skel/.config/kdeglobals \
    --group Icons \
    --key Theme "Papirus-Dark"
```

### Customizing Folder Colors (Optional)

Papirus supports colored folders:

```dockerfile
# Install papirus-folders tool for custom folder colors
RUN rpm-ostree install papirus-folders

# Set folder color to match ROCm blue theme
RUN papirus-folders -C blue --theme Papirus-Dark
```

**Available folder colors:**
- `blue` (matches ROCm theme!)
- `cyan` (for compute accent)
- `violet` (for GPU purple)
- `indigo`, `bluegrey`, `nordic`, and more

---

## 3. Color Scheme & Theming

### KDE Plasma Theme (Aurora base)

**Recommended themes:**
- **Plasma Theme:** Breeze Dark (default) with custom accent colors
- **Window Decorations:** Breeze with blue accents
- **Application Style:** Breeze Dark
- **GTK Theme:** Breeze-Dark

### Custom Accent Colors

**ROCm-inspired palette:**
```
Primary Blue:    #1E88E5  (ROCm blue)
Accent Cyan:     #00BCD4  (Compute cyan)
Highlight Purple:#7C4DFF  (GPU purple)
Dark Background: #1A1A1A  (Near black)
Secondary Dark:  #2D2D2D  (Panel gray)
```

### Containerfile Implementation

```dockerfile
# Install additional themes and icons
RUN rpm-ostree install \
    breeze-gtk \
    breeze-icon-theme \
    papirus-icon-theme \
    kde-style-breeze

# Papirus has variants - use Papirus-Dark for best dark theme compatibility
# Available variants: Papirus, Papirus-Dark, Papirus-Light, ePapirus, ePapirus-Dark

# Custom Plasma color scheme
COPY plasma-colorscheme/AtomicROCm.colors /usr/share/color-schemes/

# Set default theme for new users (Plasma 6)
RUN kwriteconfig6 --file /etc/skel/.config/kdeglobals --group General --key ColorScheme "AtomicROCm" && \
    kwriteconfig6 --file /etc/skel/.config/kdeglobals --group Icons --key Theme "Papirus-Dark"
```

---

## 3. Custom Color Scheme File

**Create:** `wallpapers/plasma-colorscheme/AtomicROCm.colors`

```ini
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=45,45,45
BackgroundNormal=35,35,35
DecorationFocus=30,136,229
DecorationHover=0,188,212
ForegroundActive=0,188,212
ForegroundInactive=112,125,138
ForegroundLink=30,136,229
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=124,77,255

[Colors:Selection]
BackgroundAlternate=30,136,229
BackgroundNormal=30,136,229
DecorationFocus=0,188,212
DecorationHover=124,77,255
ForegroundActive=252,252,252
ForegroundInactive=239,240,241
ForegroundLink=253,188,75
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=189,195,199

[Colors:Tooltip]
BackgroundAlternate=26,26,26
BackgroundNormal=35,35,35
DecorationFocus=30,136,229
DecorationHover=0,188,212
ForegroundActive=0,188,212
ForegroundInactive=112,125,138
ForegroundLink=30,136,229
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=124,77,255

[Colors:View]
BackgroundAlternate=26,26,26
BackgroundNormal=26,26,26
DecorationFocus=30,136,229
DecorationHover=0,188,212
ForegroundActive=0,188,212
ForegroundInactive=112,125,138
ForegroundLink=30,136,229
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=124,77,255

[Colors:Window]
BackgroundAlternate=45,45,45
BackgroundNormal=35,35,35
DecorationFocus=30,136,229
DecorationHover=0,188,212
ForegroundActive=0,188,212
ForegroundInactive=112,125,138
ForegroundLink=30,136,229
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=239,240,241
ForegroundPositive=39,174,96
ForegroundVisited=124,77,255

[General]
ColorScheme=AtomicROCm
Name=Atomic ROCm
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=35,35,35
activeBlend=255,255,255
activeForeground=239,240,241
inactiveBackground=35,35,35
inactiveBlend=75,71,67
inactiveForeground=112,125,138
```

---

## 4. SDDM Login Theme (Optional)

**Custom login screen with ROCm branding:**

```dockerfile
# Install SDDM theme dependencies
RUN rpm-ostree install \
    sddm-breeze \
    sddm-kcm

# Custom SDDM background
COPY wallpapers/sddm-background.jpg /usr/share/sddm/themes/breeze/background.jpg
```

---

## 5. Konsole Color Scheme

**Dark terminal with blue/cyan accents:**

```dockerfile
# Custom Konsole color scheme
COPY konsole/AtomicROCm.colorscheme /usr/share/konsole/

# Set as default for new users (Plasma 6)
RUN mkdir -p /etc/skel/.local/share/konsole && \
    echo "[Desktop Entry]" > /etc/skel/.local/share/konsole/AtomicROCm.profile && \
    echo "ColorScheme=AtomicROCm" >> /etc/skel/.local/share/konsole/AtomicROCm.profile && \
    kwriteconfig6 --file /etc/skel/.config/konsolerc --group "Desktop Entry" --key DefaultProfile "AtomicROCm.profile"
```

---

## 6. Directory Structure in Repo

```
atomic-rocm/
├── Containerfile
├── wallpapers/
│   ├── rocm-dark-blue.jpg         (4K, primary wallpaper)
│   ├── rocm-purple-gradient.jpg   (4K, alternative)
│   ├── rocm-cyan-abstract.jpg     (4K, alternative)
│   ├── sddm-background.jpg        (1080p, login screen)
│   └── plasma-colorscheme/
│       └── AtomicROCm.colors
├── konsole/
│   └── AtomicROCm.colorscheme
└── .github/
    └── workflows/
        └── build.yml
```

---

## 7. Wallpaper Sources

### Option 1: Generate with AI
- Use DALL-E, Midjourney, or Stable Diffusion
- Prompts: "Dark blue and cyan abstract wallpaper, ROCm compute theme, 4K"

### Option 2: Manual Creation
- Use GIMP/Inkscape with ROCm color palette
- Geometric patterns, gradients, GPU-inspired designs

### Option 3: Community Sources
- Unsplash/Pexels dark tech wallpapers
- Customize with ROCm branding overlay

---

## 8. Updated Containerfile Section

**Add to existing Containerfile:**

```dockerfile
# ============================================
# THEMING & BRANDING
# ============================================

# Install theme packages
RUN rpm-ostree install \
    breeze-gtk \
    breeze-icon-theme \
    papirus-icon-theme \
    kde-style-breeze \
    sddm-breeze

# Copy custom assets
COPY wallpapers/rocm-dark-blue.jpg /usr/share/backgrounds/atomic-rocm/
COPY wallpapers/rocm-purple-gradient.jpg /usr/share/backgrounds/atomic-rocm/
COPY wallpapers/rocm-cyan-abstract.jpg /usr/share/backgrounds/atomic-rocm/
COPY wallpapers/plasma-colorscheme/AtomicROCm.colors /usr/share/color-schemes/
COPY konsole/AtomicROCm.colorscheme /usr/share/konsole/

# Set default wallpaper (Plasma 6)
RUN mkdir -p /etc/skel/.config && \
    kwriteconfig6 --file /etc/skel/.config/plasmarc \
        --group Wallpaper \
        --key Image "/usr/share/backgrounds/atomic-rocm/rocm-dark-blue.jpg"

# Apply custom color scheme (Plasma 6)
RUN kwriteconfig6 --file /etc/skel/.config/kdeglobals \
        --group General \
        --key ColorScheme "AtomicROCm" && \
    kwriteconfig6 --file /etc/skel/.config/kdeglobals \
        --group Icons \
        --key Theme "Papirus-Dark"

# Custom Konsole profile (Plasma 6)
RUN mkdir -p /etc/skel/.local/share/konsole && \
    echo "[Desktop Entry]" > /etc/skel/.local/share/konsole/AtomicROCm.profile && \
    echo "ColorScheme=AtomicROCm" >> /etc/skel/.local/share/konsole/AtomicROCm.profile && \
    kwriteconfig6 --file /etc/skel/.config/konsolerc \
        --group "Desktop Entry" \
        --key DefaultProfile "AtomicROCm.profile"
```

---

## 9. Testing Theming

**After building the image:**

```bash
# Boot into Atomic-ROCm
# Check wallpaper
ls /usr/share/backgrounds/atomic-rocm/

# Check color scheme
ls /usr/share/color-schemes/AtomicROCm.colors

# Verify default settings (Plasma 6)
kreadconfig6 --file ~/.config/kdeglobals --group General --key ColorScheme
kreadconfig6 --file ~/.config/plasmarc --group Wallpaper --key Image
```

---

## 10. Quick Start: Minimal Theming

**If you want to start simple:**

```dockerfile
# Just add a wallpaper and dark theme
RUN rpm-ostree install papirus-icon-theme

COPY wallpapers/rocm-dark.jpg /usr/share/backgrounds/atomic-rocm/

RUN mkdir -p /etc/skel/.config && \
    kwriteconfig6 --file /etc/skel/.config/plasmarc \
        --group Wallpaper \
        --key Image "/usr/share/backgrounds/atomic-rocm/rocm-dark.jpg" && \
    kwriteconfig6 --file /etc/skel/.config/kdeglobals \
        --group Icons \
        --key Theme "Papirus-Dark"
```

---

## 11. Glassy Borders & Transparent Windows (The Good Stuff!)

### Enable Compositor Effects (Plasma 6)

**Blur, transparency, and vibrant colors:**

```dockerfile
# Enable KWin compositor with blur effects
RUN mkdir -p /etc/skel/.config && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Compositing --key Enabled true && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Compositing --key Backend OpenGL && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Compositing --key GLCore true

# Enable Blur effect for transparent windows
RUN kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key blurEnabled true && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Effect-blur --key BlurStrength 8 && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Effect-blur --key NoiseStrength 2

# Enable wobbly windows (fun!)
RUN kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key wobblywindowsEnabled true

# Enable magic lamp minimize effect
RUN kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key magiclampEnabled true

# Enable slide animations
RUN kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key slideEnabled true
```

### Transparent Panel & Widgets

```dockerfile
# Make panel translucent with blur
RUN kwriteconfig6 --file /etc/skel/.config/plasmashellrc --group PlasmaViews --group Panel --group Defaults --key panelOpacity 75

# Alternative: Adaptive panel transparency (auto-hides when windows touch it)
RUN kwriteconfig6 --file /etc/skel/.config/plasmashellrc --group PlasmaViews --group Panel --group Defaults --key panelVisibility 1
```

### Window Decorations with Transparency

**Install and use Sierra Breeze Enhanced (glassy look):**

```dockerfile
# Install glassy window decoration theme
RUN rpm-ostree install \
    kwin-decoration-sierra-breeze-enhanced

# Set as default window decoration
RUN kwriteconfig6 --file /etc/skel/.config/kwinrc --group org.kde.kdecoration2 --key library org.kde.sierrabreezeenhanced && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__SierraBreezeEnhanced
```

**Alternative: Use Klassy (modern macOS-style decorations):**

```dockerfile
# Install Klassy window decorations (transparent, modern)
RUN rpm-ostree install klassy

# Configure for maximum glassy effect
RUN kwriteconfig6 --file /etc/skel/.config/klassyrc --group Windeco --key DrawBackgroundGradient true && \
    kwriteconfig6 --file /etc/skel/.config/klassyrc --group Windeco --key TitleBarOpacity 60 && \
    kwriteconfig6 --file /etc/skel/.config/klassyrc --group Windeco --key BlurBehindTitle true
```

### Vibrant Color Accents

**Update color scheme with MORE saturation:**

```ini
# In AtomicROCm.colors, boost the colors:

[Colors:Selection]
BackgroundNormal=30,136,229       # Bright ROCm blue
DecorationHover=124,77,255        # Vivid purple
ForegroundActive=0,255,255        # Bright cyan

[Colors:View]
DecorationFocus=0,188,212         # Bright cyan accent
ForegroundLink=100,200,255        # Brighter blue links
```

### Plasma Theme with Transparency

**Use a transparent Plasma theme:**

```dockerfile
# Install transparent Plasma themes
RUN rpm-ostree install \
    plasma-theme-breeze-twilight

# Or configure default Breeze for transparency
RUN kwriteconfig6 --file /etc/skel/.config/plasmarc --group Theme --key name "breeze-dark" && \
    kwriteconfig6 --file /etc/skel/.config/kdeglobals --group KDE --key widgetStyle Breeze
```

### Latte Dock (Optional - Extra Glassy!)

**Add Latte Dock for macOS-style transparent dock:**

```dockerfile
# Install Latte Dock
RUN rpm-ostree install latte-dock

# Auto-start Latte Dock
RUN mkdir -p /etc/skel/.config/autostart && \
    cp /usr/share/applications/org.kde.latte-dock.desktop /etc/skel/.config/autostart/

# Latte config with transparency
RUN mkdir -p /etc/skel/.config/latte && \
    cat > /etc/skel/.config/latte/Default.layout.latte << 'EOF'
[Containments][1]
plugin=org.kde.latte.containment
backgroundStyle=2
transparency=85
blurEnabled=true
EOF
```

### Complete Glassy Setup

**Put it all together:**

```dockerfile
# ============================================
# GLASSY TRANSPARENCY & EFFECTS
# ============================================

# Install visual effects packages
RUN rpm-ostree install \
    klassy \
    latte-dock \
    kwin-effects-extra

# Enable compositor with blur
RUN kwriteconfig6 --file /etc/skel/.config/kwinrc --group Compositing --key Enabled true && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Compositing --key Backend OpenGL && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key blurEnabled true && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Effect-blur --key BlurStrength 10 && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Effect-blur --key NoiseStrength 3

# Glassy window decorations (Klassy)
RUN kwriteconfig6 --file /etc/skel/.config/kwinrc --group org.kde.kdecoration2 --key library org.kde.klassy && \
    kwriteconfig6 --file /etc/skel/.config/klassyrc --group Windeco --key TitleBarOpacity 70 && \
    kwriteconfig6 --file /etc/skel/.config/klassyrc --group Windeco --key BlurBehindTitle true && \
    kwriteconfig6 --file /etc/skel/.config/klassyrc --group Windeco --key DrawBackgroundGradient true

# Transparent panel (80% opacity)
RUN kwriteconfig6 --file /etc/skel/.config/plasmashellrc --group PlasmaViews --group Panel --group Defaults --key panelOpacity 80

# Enable fun effects
RUN kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key wobblywindowsEnabled true && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key magiclampEnabled true && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key slideEnabled true && \
    kwriteconfig6 --file /etc/skel/.config/kwinrc --group Plugins --key glideEnabled true

# Konsole transparency (70%)
RUN kwriteconfig6 --file /etc/skel/.config/konsolerc --group Desktop\ Entry --key DefaultProfile AtomicROCm.profile && \
    mkdir -p /etc/skel/.local/share/konsole && \
    echo "[Appearance]" >> /etc/skel/.local/share/konsole/AtomicROCm.profile && \
    echo "ColorScheme=AtomicROCm" >> /etc/skel/.local/share/konsole/AtomicROCm.profile && \
    echo "[General]" >> /etc/skel/.local/share/konsole/AtomicROCm.profile && \
    echo "Opacity=0.7" >> /etc/skel/.local/share/konsole/AtomicROCm.profile && \
    echo "Blur=true" >> /etc/skel/.local/share/konsole/AtomicROCm.profile
```

### Wallpaper Recommendations for Glassy Look

**Works best with:**
- Bright, colorful gradients (blue → cyan → purple)
- Abstract light/particle effects
- Bokeh backgrounds
- Vibrant space/nebula images
- Neon cityscapes

**Avoid:**
- Pure black backgrounds (makes transparency less visible)
- Flat, solid colors

### Testing Transparency

**After boot:**

```bash
# Check if compositor is running
qdbus org.kde.KWin /Compositor active

# Test blur effect
qdbus org.kde.KWin /Effects isEffectLoaded blur

# Check transparency settings
kreadconfig6 --file ~/.config/kwinrc --group Plugins --key blurEnabled
kreadconfig6 --file ~/.config/klassyrc --group Windeco --key TitleBarOpacity
```

---

## Next Steps

1. **Create/find wallpapers** (dark blue/cyan/purple theme)
2. **Test color scheme** on current Fedora 43 KDE
3. **Add to Containerfile** before building image
4. **Build test image** to verify theming works
5. **Iterate** on colors/wallpapers based on look

---

**Created:** 2026-01-04
**For:** Atomic-ROCm immutable OS image
**Backup will complete soon, then ready to add theming to build!**
