# TypelessOS Product Overview

Build and run the app for the user with
```bash
xcodebuild -project TypelessOS.xcodeproj -scheme TypelessOS -configuration Release build && \
killall TypelessOS 2>/dev/null; \
sleep 1; \
open ~/Library/Developer/Xcode/DerivedData/TypelessOS-*/Build/Products/Release/TypelessOS.app
```


TypelessOS is a macOS menu bar application that provides an AI-powered assistant with integrated terminal capabilities.

## Core Value Proposition
- Effortless AI interaction from the system tray
- Execute terminal commands directly through AI conversations
- Voice input via whisper.cpp speech recognition
- Multi-provider AI support (Gemini, OpenAI, Groq)

## Key Features
- **Chat Panel**: Primary AI interface accessible from menu bar
- **Terminal Integration**: Execute commands via AI tool calls with live output
- **Terminal Bubbles**: Minimize running commands to floating indicators
- **Full Terminal Window**: Pop out to interactive PTY session
- **Floating Island**: Status overlay for voice recording and system state
- **Notepad**: Quick notes with markdown support
- **WebKit Views**: Direct access to ChatGPT, Claude, Gemini web interfaces
- **Google Tasks Integration**: Task management via Google Tasks API

## User Flow
1. Click menu bar icon → Chat panel appears
2. Chat with AI → AI can suggest/execute terminal commands
3. Command output appears inline → Can minimize to bubble or expand to full terminal
4. Voice input available via whisper.cpp integration
