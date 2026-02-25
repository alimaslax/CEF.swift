---
description: TypelessOS project-specific conventions and architecture patterns
alwaysApply: true
---

# TypelessOS Conventions

## Architecture Overview
TypelessOS is a macOS menu bar app built with SwiftUI, featuring AI assistants, speech recognition, and Google service integrations.

---

## Layer Structure

### Api Layer (`TypelessOS/Api/`)
External API clients and network communication:
- `GeminiApi.swift` - Google Gemini AI client
- `GroqApi.swift` - Groq AI client  
- `OpenAIApi.swift` - OpenAI/ChatGPT client
- `ChatApiProtocol.swift` - Common AI chat interface
- `SystemPrompts.swift` - AI system prompts configuration
- `DTO/` - Data Transfer Objects for API responses

### Core Layer (`TypelessOS/Core/`)
Business logic and application services:

#### Services (`Core/Services/`)
- `AuthService.swift` - Google OAuth authentication
- `GmailService.swift` - Gmail API integration
- `GoogleTasksService.swift` - Google Tasks API integration
- `ChatService.swift` - Chat management and history
- `SpeechService.swift` - Speech synthesis
- `WhisperModelService.swift` - Whisper model management
- `EventMonitorService.swift` - Global keyboard/mouse events
- `TerminalService.swift` - Terminal management
- `TerminalExecutionService.swift` - Command execution
- `TerminalServerClient.swift` - Terminal server communication
- `NotepadService.swift` - Notes management
- `APIKeyService.swift` - API key storage (Keychain)

#### Repositories (`Core/Repositories/`)
Data persistence and storage:
- `ChatRepository.swift` - Chat history persistence
- `NoteRepository.swift` - Notes persistence
- `SettingsRepository.swift` - User settings (UserDefaults)
- `CommandHistoryRepository.swift` - Terminal command history

#### Dependency Injection
- `DependencyContainer.swift` - Service registration and resolution

### Models Layer (`TypelessOS/Models/`)
Data models and state objects:
- `WhisperState.swift` - Speech recognition state
- `Note.swift` - Note data model
- `SavedChat.swift` - Chat conversation model
- `User.swift` - User model
- `APIProvider.swift` - AI provider enum
- `AppTab.swift` - Navigation tab enum

### UI Layer (`TypelessOS/UI/`)
SwiftUI views organized by feature:
- `MainView.swift` - Primary container with tab navigation
- `Assistant/` - AI chat interfaces (Native + WebKit)
- `Notepad/` - Notes, tasks, and email views
- `Settings/` - Preferences and about screens
- `StatusBars/` - Menu bar and floating island
- `Terminal/` - Terminal emulator views
- `Components/` - Reusable UI components

### Utils Layer (`TypelessOS/Utils/`)
Shared utilities and helpers

---

## Key Patterns

### Window Management
- Menu bar app using `NSStatusItem` for system tray
- `TransparentView` windows for floating UI
- Chat panel hides/shows via alpha and `ignoresMouseEvents`
- Position relative to status bar button
- Use `NSApp.activate(ignoringOtherApps: true)` for focus

### UI Design
- Dark theme (background ~0.08-0.12 white)
- Glassmorphism effects with `NSVisualEffectView`
- Floating panel positioning below menu bar
- Smooth transitions with `withAnimation`

### Core Components
- `AppDelegate`: App lifecycle, window management, status bar
- `MainView`: Primary SwiftUI container with navigation
- `WhisperState`: Speech recognition using whisper.cpp
- `DependencyContainer`: Centralized dependency injection

---

## File Naming Conventions
- Services: `*Service.swift`
- Repositories: `*Repository.swift`
- API clients: `*Api.swift`
- Views: `*View.swift`
- View Models: `*ViewModel.swift`
