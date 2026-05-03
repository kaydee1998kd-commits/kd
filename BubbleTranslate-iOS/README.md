# 🔵 Bubble Translate - iOS Floating Translator

A native iOS app for **jailbroken iPhone 6s** running **iOS 15.8.5** that creates a floating bubble overlay on your screen. When you tap the bubble, it captures the screen, reads Chinese text using OCR, and instantly translates it to English.

Designed specifically for use with **Xianyu (闲鱼)** — the Chinese secondhand marketplace.

## ✨ Features

- 🔵 **Floating Bubble** — Stays on top of ALL apps, never leaves the screen
- 📸 **Screen Capture OCR** — Captures the current screen and reads Chinese text using Vision framework
- 🌐 **AI Translation** — Chinese → English powered by AI backend
- 📋 **Clipboard Fallback** — If OCR fails, translates from clipboard
- 🔊 **Text-to-Speech** — Listen to the English translation
- 📱 **Draggable Bubble** — Drag to reposition, snaps to screen edges
- ⚡ **Instant** — Tap the bubble, get translation in seconds
- 🎨 **Beautiful UI** — Gradient bubble, dark theme, smooth animations

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│              Any App (Xianyu)           │
│  ┌──────────────────────────────────┐   │
│  │     Chinese Content 你好世界      │   │
│  │                                  │   │
│  │  ┌───┐                          │   │
│  │  │中→A│ ← Floating Bubble        │   │
│  │  └───┘   (UIWindow max level)   │   │
│  │                                  │   │
│  └──────────────────────────────────┘   │
│                                         │
│  User taps bubble →                     │
│  1. Screen captured (CGWindowList)      │
│  2. Vision OCR reads Chinese text       │
│  3. API translates 中文 → English        │
│  4. Translation panel appears           │
└─────────────────────────────────────────┘
```

## 📁 Project Structure

```
BubbleTranslate-iOS/
├── BubbleTranslate/
│   ├── App/
│   │   └── AppDelegate.swift          # App launch, starts bubble service
│   ├── Managers/
│   │   └── FloatingBubbleManager.swift # Core: overlay window, bubble lifecycle
│   ├── Services/
│   │   ├── OCRService.swift           # Screen capture + Vision OCR
│   │   └── TranslationService.swift   # API calls for translation
│   ├── Views/
│   │   ├── BubbleView.swift           # The floating bubble button
│   │   ├── TranslationPanelView.swift # Translation results panel
│   │   └── MainViewController.swift   # Settings screen
│   ├── Models/
│   │   └── Models.swift               # Data models & config
│   ├── Extensions/
│   │   └── Extensions.swift           # UIWindow overlay, UIColor, etc.
│   ├── Resources/
│   │   └── LaunchScreen.storyboard    # Launch screen
│   ├── Info.plist                     # App configuration
│   └── BubbleTranslate.entitlements   # App entitlements
├── project.yml                        # XcodeGen project spec
├── ExportOptions.plist                # IPA export settings
├── Makefile                           # Build automation
└── README.md                          # This file
```

## 🔧 Requirements

### Build Machine
- macOS with Xcode 14+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- `ldid` for fake signing (`brew install ldid`)

### Target Device
- **iPhone 6s** (or any jailbroken iOS device)
- **iOS 15.8.5** (works on iOS 15.0+)
- **Jailbroken** — Required for:
  - Floating overlay window that persists across apps
  - Screen capture of other apps
  - Background process keeping

### Translation Server
You need the Next.js translation backend running. It's included in the parent project.

## 🚀 Build Instructions

### Step 1: Generate Xcode Project

```bash
cd BubbleTranslate-iOS
xcodegen generate
```

### Step 2: Build the App

```bash
# Option A: Using Make
make build

# Option B: Manual xcodebuild
xcodebuild clean build \
  -project BubbleTranslate.xcodeproj \
  -scheme BubbleTranslate \
  -configuration Release \
  -sdk iphoneos \
  -arch arm64 \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

### Step 3: Create IPA

```bash
# Option A: Using Make
make ipa

# Option B: Manual IPA creation
make archive
make manual-ipa
```

### Step 4: Deploy to Jailbroken iPhone

#### Method A: Direct Install (SSH/SCP)
```bash
# Transfer IPA to device
scp build/BubbleTranslate.ipa root@<device-ip>:/var/root/

# SSH into device and install
ssh root@<device-ip>
dpkg -i /var/root/BubbleTranslate.ipa
killall SpringBoard
```

#### Method B: Using Filza
1. Transfer `BubbleTranslate.ipa` to device
2. Open with Filza
3. Install the IPA
4. Respring

#### Method C: Using AppSync Unified
1. Install AppSync Unified from Cydia
2. Use AltStore/Sideloadly to sideload the IPA

### Step 5: Start Translation Server

The iOS app needs a translation API backend. Start the Next.js server:

```bash
cd ..  # Back to the main project
bun run dev
```

Then in the Bubble Translate app settings, enter your server URL:
- **Local**: `http://<your-computer-ip>:3000`
- **Deployed**: `https://your-server.com`

## 🎯 How to Use

### With Xianyu (闲鱼)

1. Open **Bubble Translate** app once (starts the floating bubble)
2. Switch to **Xianyu** app
3. Browse any product listing with Chinese text
4. **Tap the floating bubble** (中→A)
5. The app will:
   - Capture the screen
   - Read all Chinese text with OCR
   - Translate to English
   - Show results in a floating panel
6. **Copy** the translation or **listen** to it

### Tips

- **Drag the bubble** to reposition it (snaps to screen edges)
- **Tap the bubble** to capture & translate
- **Tap outside** the translation panel to dismiss it
- **Copy Chinese text first** then tap bubble for clipboard translation fallback
- The bubble **stays on screen** even when you switch apps

## ⚙️ Configuration

### Change Translation Server URL

In `BubbleTranslate/Models/Models.swift`:

```swift
struct AppConfig {
    // Change this to your server URL
    static let translationAPIBaseURL = "http://YOUR_SERVER_IP:3000"
}
```

Or change it at runtime in the app's Settings screen.

## 🔑 How the Floating Bubble Works (Jailbreak)

On a jailbroken iPhone, this app uses several techniques to keep the bubble visible:

1. **Maximum Window Level**: The overlay `UIWindow` uses `windowLevel = .greatestFiniteMagnitude` to stay on top of everything including the status bar and other apps.

2. **Background Persistence**: On jailbroken iOS, apps can continue running in the background. The app uses infinite background tasks and BackBoardServices to prevent suspension.

3. **Screen Capture**: Uses `CGWindowListCreateImage` with `.optionOnScreenBelowWindow` to capture the screen content of the current foreground app — this only works on jailbroken devices.

4. **Keep-Alive Timer**: A periodic timer ensures the overlay window remains visible and re-asserts its window level.

## 🛠️ Troubleshooting

### Bubble disappears after switching apps
- Make sure your device is properly jailbroken
- Check that BackBoardServices framework is loaded
- Try disabling any tweak that manages window levels (e.g., floating tweaks)

### OCR doesn't detect text
- Make sure the Chinese text is clearly visible on screen
- The text should be large enough (minimum 2% of screen height)
- Try copying the text to clipboard first as a fallback

### Translation fails
- Make sure the Next.js backend is running and accessible
- Check the server URL in Settings
- The device and server must be on the same network (if using local server)

### App crashes on launch
- Make sure you're on iOS 15.0+
- Check that AppSync Unified is installed (Cydia)
- Try rebuilding with `make clean && make build`

## 📝 License

MIT License - Use freely for personal purposes.

## 🙏 Credits

- Built with UIKit + Vision framework
- Translation powered by AI
- Inspired by Bubble Translate for Android
