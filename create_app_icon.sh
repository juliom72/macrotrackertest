#!/bin/bash

# Script to create app icon using SF Symbols
# This requires macOS and SF Symbols app

echo "Creating app icon..."

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Create a SwiftUI view that renders the icon
cat > IconView.swift << 'EOF'
import SwiftUI

struct IconView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.green, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 600))
                .foregroundColor(.white)
        }
        .frame(width: 1024, height: 1024)
    }
}
EOF

echo "✅ Icon view created"
echo "📝 To generate the PNG:"
echo "   1. Open SF Symbols app (comes with Xcode)"
echo "   2. Search for 'fork.knife.circle.fill'"
echo "   3. Export at 1024x1024"
echo "   4. Or use the instructions in APP_ICON_INSTRUCTIONS.md"
