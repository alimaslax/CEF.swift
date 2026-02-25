# TypelessOS Tech Stack

Build and run the app for the user with
```bash
xcodebuild -project TypelessOS.xcodeproj -scheme TypelessOS -configuration Release build && \
killall TypelessOS 2>/dev/null; \
sleep 1; \
open ~/Library/Developer/Xcode/DerivedData/TypelessOS-*/Build/Products/Release/TypelessOS.app
```

## Build System
- **Xcode Project**: `TypelessOS.xcodeproj`
- **Platform**: macOS (menu bar app)
- **Language**: Swift 5+
- **UI Framework**: SwiftUI with AppKit integration

## Key Dependencies (Swift Package Manager)
- **SwiftTerm** (1.5.1): Terminal emulation
- **SwiftyJSON** (5.0.2): JSON parsing for API responses
- **Alamofire** (5.8.1): HTTP networking
- **swift-markdown-ui** (2.4.1): Markdown rendering in chat
- **Splash** (0.16.0): Syntax highlighting
- **GoogleSignIn-iOS** (8.0.0): Google authentication
- **KeyboardShortcuts** (2.2.3): Global hotkey support
- **SwiftUI-Introspect** (0.10.0): SwiftUI/AppKit bridging

## Local Packages
- **whisper.cpp.swift**: Speech-to-text via whisper.cpp C++ library

## External Services
- **MCP Terminal Server**: Node.js server for command execution (port 8002)
- **AI Providers**: Gemini, OpenAI, Groq APIs
- **Google Tasks API**: Task management integration

## Build Commands

```bash
# Build and run (Release)
xcodebuild -project TypelessOS.xcodeproj -scheme TypelessOS -configuration Release build

# Build and run (Debug)
xcodebuild -project TypelessOS.xcodeproj -scheme TypelessOS -configuration Debug build

# Open built app (Release)
open ~/Library/Developer/Xcode/DerivedData/TypelessOS-*/Build/Products/Release/TypelessOS.app

# Open built app (Debug)
open ~/Library/Developer/Xcode/DerivedData/TypelessOS-*/Build/Products/Debug/TypelessOS.app
```

## Terminal Server Setup
```bash
cd McpTerminalServer
yarn build
yarn start --port 8002
```

## Key APIs
- Gemini: `generativelanguage.googleapis.com` (streaming SSE)
- OpenAI: Standard chat completions API
- Groq: OpenAI-compatible API
