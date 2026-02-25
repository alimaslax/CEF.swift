# TypelessOS Project Structure

Build and run the app for the user with
```bash
xcodebuild -project TypelessOS.xcodeproj -scheme TypelessOS -configuration Release build && \
killall TypelessOS 2>/dev/null; \
sleep 1; \
open ~/Library/Developer/Xcode/DerivedData/TypelessOS-*/Build/Products/Release/TypelessOS.app
```

```
TypelessOS/
├── TypelessOS.swift          # App entry point, Settings singleton
├── AppDelegate.swift         # Window management, status bar, lifecycle
│
├── Api/                      # Network layer
│   ├── ChatApiProtocol.swift # Common chat interface + factory
│   ├── GeminiApi.swift       # Google Gemini streaming
│   ├── GroqApi.swift         # Groq API client
│   ├── OpenAIApi.swift       # OpenAI API client
│   ├── SystemPrompts.swift   # AI system prompts
│   └── DTO/                  # Data transfer objects
│       ├── GeminiResponseDTO.swift
│       └── GoogleTasksDTO.swift
│
├── Core/                     # Business logic layer
│   ├── DependencyContainer.swift   # DI container (singleton)
│   ├── Repositories/         # Data persistence
│   │   ├── ChatRepository.swift
│   │   ├── CommandHistoryRepository.swift
│   │   ├── NoteRepository.swift
│   │   └── SettingsRepository.swift
│   └── Services/             # Business services
│       ├── APIKeyService.swift
│       ├── AuthService.swift
│       ├── ChatService.swift
│       ├── EventMonitorService.swift
│       ├── GoogleTasksService.swift
│       ├── NotepadService.swift
│       ├── SpeechService.swift
│       ├── TerminalExecutionService.swift
│       ├── TerminalServerClient.swift  # MCP server communication
│       └── TerminalService.swift
│
├── Models/                   # Data models
│   ├── APIProvider.swift
│   ├── AppTab.swift
│   ├── Note.swift
│   ├── SavedChat.swift
│   ├── User.swift
│   └── WhisperState.swift
│
├── UI/                       # SwiftUI views
│   ├── MainView.swift        # Main container, TransparentView window
│   ├── Assistant/
│   │   ├── AssistantChatView.swift   # Main assistant view
│   │   ├── Chat/
│   │   │   ├── APIChatView.swift     # API-based chat interface
│   │   │   └── Parts/                # Chat components
│   │   │       ├── BlinkingCursorView.swift
│   │   │       ├── ChatInputBarView.swift
│   │   │       ├── ChatViewModel.swift
│   │   │       ├── ChatsGridView.swift
│   │   │       ├── DotLoadingView.swift
│   │   │       ├── MessageRow.swift
│   │   │       ├── MessageRowView.swift
│   │   │       ├── PopOutTerminalView.swift
│   │   │       ├── PoppedOutTerminalBubbleView.swift
│   │   │       └── ProviderMenuView.swift
│   │   └── WebKit/
│   │       └── AssistantWebView.swift  # WebView wrappers
│   ├── Components/
│   │   └── CodeBlockViews.swift
│   ├── Notepad/
│   │   └── NotepadView.swift
│   ├── Settings/
│   │   ├── InfoModalView.swift
│   │   └── SettingsContentView.swift
│   ├── StatusBars/
│   │   ├── FloatingIslandView.swift
│   │   └── StatusBarView.swift
│   └── Terminal/
│       ├── SwiftTermView.swift
│       ├── TerminalComponentViews.swift
│       ├── TerminalView.swift
│       └── TerminalViewModel.swift
│
├── Utils/
│   └── AudioUtils.swift
│
├── Resources/
└── Supporting files/         # Assets, entitlements
```

## Architecture Patterns

- **Singleton Settings**: `Settings.shared` for app-wide state
- **DI Container**: `DependencyContainer.shared` for services/repos
- **Repository Pattern**: Data access abstraction (UserDefaults)
- **Protocol-based APIs**: `ChatApiProtocol` with factory pattern
- **MVVM**: ViewModels for complex views (ChatViewModel, TerminalViewModel)

## Window Types
- `TransparentView`: Main floating chat panel (borderless NSWindow)
- `SettingsWindow`: Borderless settings modal
- `NSWindow`: Full terminal window, floating island
