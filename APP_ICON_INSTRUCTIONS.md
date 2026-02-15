# App Icon Generation Instructions

To create the app icon with the fork and knife logo:

## Option 1: Using Xcode (Easiest)

1. Open your project in Xcode
2. Navigate to `Assets.xcassets` → `AppIcon`
3. In Xcode, you can use the SF Symbol directly:
   - Right-click in the 1024x1024 slot
   - Select "New Image" or drag an image
   - For a quick solution, you can use a design tool to export the SF Symbol

## Option 2: Export SF Symbol as Image

1. Open **SF Symbols** app (comes with Xcode)
2. Search for "fork.knife.circle.fill"
3. Export it at 1024x1024 size
4. Apply the green-to-blue gradient as background
5. Save as PNG

## Option 3: Use Design Tool

1. Create a 1024x1024 canvas
2. Add a gradient background (green to blue, top-left to bottom-right)
3. Add the fork.knife.circle.fill SF Symbol in white
4. Export as PNG
5. Drag into Xcode's AppIcon asset

## Quick Solution: Use Online Icon Generator

1. Create or find a fork/knife icon image
2. Use [AppIcon.co](https://www.appicon.co/) or similar tool
3. Upload your 1024x1024 image
4. Download the generated icon set
5. Replace the files in `Assets.xcassets/AppIcon.appiconset/`

## Current Icon Location

Your app icon configuration is at:
`camera-mobile-app-1/Assets.xcassets/AppIcon.appiconset/Contents.json`

You need to add the actual PNG image files to this folder.
