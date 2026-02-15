# App Icon Setup Guide

To add a logo to your app icon:

## Option 1: Using Xcode (Recommended)

1. Open your project in Xcode
2. Navigate to `Assets.xcassets` in the Project Navigator
3. Click on `AppIcon`
4. You'll see slots for different icon sizes:
   - **1024x1024** (required for App Store)
   - Dark mode variants
   - Tinted variants

5. **Add your icon image:**
   - Prepare a 1024x1024 PNG image of your logo
   - Drag and drop it into the 1024x1024 slot
   - For dark mode, you can add a different version if desired
   - For tinted mode, Xcode will automatically apply a tint

## Option 2: Using an Icon Generator Tool

You can use online tools like:
- [AppIcon.co](https://www.appicon.co/)
- [IconKitchen](https://icon.kitchen/)
- [MakeAppIcon](https://makeappicon.com/)

These tools will generate all required sizes from a single 1024x1024 image.

## Design Tips

- Use a simple, recognizable logo
- Ensure it looks good at small sizes (icons are displayed at various sizes)
- Use high contrast colors
- Avoid text that's too small to read
- Test on both light and dark backgrounds

## Current App Icon Location

Your app icon assets are located at:
`camera-mobile-app-1/Assets.xcassets/AppIcon.appiconset/`

The `Contents.json` file defines the icon slots. You just need to add the actual image files.
