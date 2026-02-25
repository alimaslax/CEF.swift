---
description: TypelessOS project structure and file locations for quick navigation
---

# Project Sitemap

## Root Structure
```
typelessOS/
├── TypelessOS/           # Main app source
├── TypelessOS.xcodeproj/ # Xcode project
├── whisper.cpp.swift/    # Speech recognition package
├── docs/                 # Documentation
└── .agent/               # Antigravity configuration
```

---

## Source Code (`TypelessOS/`)

### Entry Points
- `TypelessOS.swift` - App entry point (@main)
- `AppDelegate.swift` - App lifecycle, window management, status bar setup

---

### Api Layer (`Api/`)
External API clients and network communication:
- `ChatApiProtocol.swift` - Common AI chat interface protocol
- `GeminiApi.swift` - Google Gemini AI client
- `GroqApi.swift` - Groq AI client
- `OpenAIApi.swift` - OpenAI/ChatGPT client
- `SystemPrompts.swift` - AI system prompts configuration

#### DTOs (`Api/DTO/`)
Data transfer objects for API responses

---

### Core Layer (`Core/`)

#### Dependency Injection
- `DependencyContainer.swift` - Service registration and resolution

#### Services (`Core/Services/`)
| Service | Purpose |
|---------|---------|
| `AuthService.swift` | Google OAuth authentication |
| `GmailService.swift` | Gmail API integration |
| `GoogleTasksService.swift` | Google Tasks API integration |
| `ChatService.swift` | Chat management and history |
| `SpeechService.swift` | Speech synthesis |
| `WhisperModelService.swift` | Whisper model management |
| `EventMonitorService.swift` | Global keyboard/mouse events |
| `TerminalService.swift` | Terminal management |
| `TerminalExecutionService.swift` | Command execution |
| `TerminalServerClient.swift` | Terminal server communication |
| `NotepadService.swift` | Notes management |
| `APIKeyService.swift` | API key storage (Keychain) |

#### Repositories (`Core/Repositories/`)
| Repository | Purpose |
|------------|---------|
| `ChatRepository.swift` | Chat history persistence |
| `NoteRepository.swift` | Notes persistence |
| `SettingsRepository.swift` | User settings (UserDefaults) |
| `CommandHistoryRepository.swift` | Terminal command history |

---

### Models Layer (`Models/`)
- `WhisperState.swift` - Speech recognition state management
- `Note.swift` - Note data model
- `SavedChat.swift` - Chat conversation model  
- `User.swift` - User model
- `APIProvider.swift` - AI provider enum (Gemini, OpenAI, Groq)
- `AppTab.swift` - Navigation tab enum

---

### UI Layer (`UI/`)

#### Main Container
- `MainView.swift` - Primary SwiftUI container with tab navigation

#### Assistant (`UI/Assistant/`)
- `Api/AssistantApiView.swift` - Native AI chat interface
- `Api/Parts/` - Reusable chat UI components
- `WebKit/AssistantWebView.swift` - WebKit wrapper for ChatGPT/Claude/Gemini

#### Notepad (`UI/Notepad/`)
- Notes, tasks, and email (Inbox Intel) views

#### Status Bars (`UI/StatusBars/`)
- `StatusBarView.swift` - Menu bar icon and interactions
- `FloatingIslandView.swift` - Dynamic island-style notifications

#### Settings (`UI/Settings/`)
- `SettingsContentView.swift` - App preferences
- `InfoModalView.swift` - About/info modal

#### Terminal (`UI/Terminal/`)
- Terminal emulator views

#### Components (`UI/Components/`)
- Reusable UI components

---

### Utils Layer (`Utils/`)
- Shared utilities and helpers

---

### Resources
- `Supporting files/Assets.xcassets` - App icons and images
- `TypelessOSRelease.entitlements` - App permissions
