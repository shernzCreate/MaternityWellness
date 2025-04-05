#!/bin/bash

# Script to help set up an Xcode project for MaternityWellness app

echo "Setting up MaternityWellness Xcode Project..."

# Define project name and bundle identifier
PROJECT_NAME="MaternityWellness"
BUNDLE_ID="com.example.MaternityWellness"

# Create project directories if they don't exist
mkdir -p $PROJECT_NAME
mkdir -p $PROJECT_NAME/Models
mkdir -p $PROJECT_NAME/ViewModels
mkdir -p $PROJECT_NAME/Views
mkdir -p $PROJECT_NAME/Views/Auth
mkdir -p $PROJECT_NAME/Views/Home
mkdir -p $PROJECT_NAME/Views/Assessment
mkdir -p $PROJECT_NAME/Views/Resources
mkdir -p $PROJECT_NAME/Assets.xcassets
mkdir -p $PROJECT_NAME/Preview\ Content/Preview\ Assets.xcassets

# Create a basic Info.plist
cat > $PROJECT_NAME/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>Maternity Wellness</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
EOF

# Create a placeholder for Assets catalog
cat > $PROJECT_NAME/Assets.xcassets/Contents.json << EOF
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create a placeholder for preview assets
cat > $PROJECT_NAME/Preview\ Content/Preview\ Assets.xcassets/Contents.json << EOF
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "Basic project structure created!"
echo ""
echo "NEXT STEPS:"
echo "1. Open Xcode and create a new iOS App project"
echo "2. Name it '$PROJECT_NAME'"
echo "3. Choose SwiftUI for the interface"
echo "4. Select the directory where you cloned this repository"
echo "5. Once created, copy all Swift files from this repository to your project"
echo "6. Make sure to create the following color assets in Assets.xcassets:"
echo "   - AccentColor"
echo "   - GreatMood (bright green)"
echo "   - GoodMood (light green)"
echo "   - OkayMood (yellow)"
echo "   - SadMood (orange)"
echo "   - TerribleMood (red)"
echo ""
echo "Setup complete! You should now have a working project structure."