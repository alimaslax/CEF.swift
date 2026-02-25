# New Session

Exported: 1/30/2026, 2:37:09 PM

## Steering Documents

**Workspace:**
- product.md
- structure.md
- tech.md
- navigation-sitemap.md

---

**User:**

Phase 1: Structural Audit & Namespace Definition
Before writing code, Claude must map the current mess and define the new "Source of Truth."
Inventory: Index all existing functions, @State variables, and hardcoded logic.
The DRY Mapping: Identify recurring logic (e.g., event listeners, API calls, string formatting) that must be extracted into Services.
Naming Convention: Standardize file naming. (e.g., [Feature]View.swift, [Feature]ViewModel.swift, [Feature]Service.swift).
Phase 2: Dependency & Service Layer (The Foundation)
Claude will extract all "doing" logic out of the UI.
Service Extraction: Create standalone, protocol-backed Services for core OS interactions.
Dependency Injection: Implement a simple Container or use @Environment to inject these services. This ensures that logic isn't tied to a specific view.
Model Purification: Ensure Models are simple structs with no logic, used only for data transport.
Phase 3: ViewModel Migration (The Brains)
Claude will now "gut" the Views.
Logic Transfer: Every @State or @Binding that handles business logic (e.g., processing text, toggling settings) moves to a corresponding ObservableObject ViewModel.
Unidirectional Data Flow: Ensure the View only "observes" the ViewModel and sends "intents" (actions) back to it.
Phase 4: View Refactoring & Componentization
UI Pruning: Views should contain only layout code. If a View is longer than 100 lines, Claude must break it into smaller sub-components.
Modern Swift Patterns: Use @StateObject and @Published strictly to maintain a clean lifecycle.
Phase 5: File System Execution & Cleanup
This is the "Agentic" command. Tell Claude to generate a Manifest of Change:
New File List: A list of every file to be created.
Renaming Map: Old filename → New filename.
Deletions: A list of files that are now redundant because their logic was merged or abstracted.

---

**Assistant:**

This is a substantial refactoring project. Let me start with Phase 1: a comprehensive structural audit of the codebase to understand what we're working with before proposing changes.

Now let me read the remaining key files to complete the audit:

Now let me read the remaining critical files to complete the audit:

Now I have a comprehensive understanding of the codebase. Let me create the complete refactoring manifest.

---

# TypelessOS Refactoring Manifest

## Phase 1: Structural Audit Summary

### Current State Inventory

| Category | Count | Issues |
|----------|-------|--------|
| @Published properties | 40+ | Scattered across 8+ classes |
| Business logic in Views | ~800 lines | MainView, ChatView, UnifiedChatView |
| Code duplication | ~400 lines | API classes 95% identical |
| Singletons | 6 | Settings, AuthManager, NoteManager, ChatHistoryManager, GoogleTasksService, TerminalServerClient |
| Circular dependencies | 2 | ViewModel ↔ TerminalController |

### DRY Violations Identified

1. **API Classes** - `GeminiApi`, `OpenAIApi`, `GroqApi` share 95% identical code
2. **Persistence Logic** - Duplicated file I/O patterns in `NoteManager`, `ChatHistoryManager`, `AuthManager`
3. **MainActor dispatching** - `await MainActor.run { }` repeated 15+ times
4. **JSON body construction** - Each API builds messages differently but with same structure
5. **Error handling** - No unified error type, each service handles errors independently

---

## Phase 2: New Architecture Definition

### Naming Convention
```
[Feature]View.swift       - Pure UI layout
[Feature]ViewModel.swift  - ObservableObject state management
[Feature]Service.swift    - Business logic, API calls, side effects
[Feature]Repository.swift - Data persistence layer
```

### Target Directory Structure
```
TypelessOS/
├── App/
│   ├── TypelessOSApp.swift          # @main entry point
│   ├── AppDelegate.swift            # Window management only
│   └── DependencyContainer.swift    # DI container
│
├── Core/
│   ├── Services/
│   │   ├── ChatService.swift        # Chat orchestration
│   │   ├── TerminalService.swift    # Terminal execution
│   │   ├── SpeechService.swift      # Whisper integration
│   │   ├── AuthService.swift        # OAuth handling
│   │   └── APIKeyService.swift      # Centralized key management
│   │
│   ├── Repositories/
│   │   ├── ChatRepository.swift     # Chat persistence
│   │   ├── NoteRepository.swift     # Note persistence
│   │   └── SettingsRepository.swift # UserDefaults abstraction
│   │
│   ├── Networking/
│   │   ├── ChatAPIProtocol.swift    # Protocol definition
│   │   ├── ChatAPIClient.swift      # Unified API client
│   │   ├── Adapters/
│   │   │   ├── GeminiAdapter.swift
│   │   │   ├── OpenAIAdapter.swift
│   │   │   └── GroqAdapter.swift
│   │   └── TerminalServerClient.swift
│   │
│   └── Models/
│       ├── Message.swift
│       ├── Chat.swift
│       ├── Note.swift
│       ├── User.swift
│       ├── APIProvider.swift
│       └── AppSettings.swift
│
├── Features/
│   ├── Chat/
│   │   ├── ChatView.swift
│   │   ├── ChatViewModel.swift
│   │   └── Components/
│   │       ├── MessageRowView.swift
│   │       ├── ChatInputBar.swift
│   │       └── ChatsGridView.swift
│   │
│   ├── Terminal/
│   │   ├── TerminalView.swift
│   │   ├── TerminalViewModel.swift
│   │   └── Components/
│   │       ├── TerminalOutputView.swift
│   │       └── TerminalBubbleView.swift
│   │
│   ├── Notepad/
│   │   ├── NotepadView.swift
│   │   └── NotepadViewModel.swift
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── SettingsViewModel.swift
│   │
│   └── StatusBar/
│       ├── StatusBarView.swift
│       └── FloatingIslandView.swift
│
├── Shared/
│   ├── Views/
│   │   ├── NonDraggableWindowArea.swift
│   │   ├── BlinkingCursorView.swift
│   │   └── DotLoadingView.swift
│   │
│   ├── Extensions/
│   │   ├── String+Error.swift
│   │   └── View+Modifiers.swift
│   │
│   └── Utilities/
│       ├── EventMonitors.swift
│       └── AudioUtils.swift
│
└── Resources/
    ├── Assets.xcassets/
    └── models/
```

---

## Phase 3: Manifest of Changes

### New Files to Create

| File | Purpose |
|------|---------|
| `Core/Services/ChatService.swift` | Orchestrates chat operations, provider switching, history |
| `Core/Services/TerminalService.swift` | Terminal command execution, session management |
| `Core/Services/SpeechService.swift` | Whisper recording/transcription |
| `Core/Services/APIKeyService.swift` | Centralized API key management |
| `Core/Repositories/ChatRepository.swift` | Chat persistence (extracted from ChatHistoryManager) |
| `Core/Repositories/NoteRepository.swift` | Note persistence (extracted from NoteManager) |
| `Core/Repositories/SettingsRepository.swift` | UserDefaults abstraction |
| `Core/Networking/ChatAPIClient.swift` | Unified API client with adapter pattern |
| `Core/Networking/Adapters/GeminiAdapter.swift` | Gemini-specific request/response handling |
| `Core/Networking/Adapters/OpenAIAdapter.swift` | OpenAI-specific handling |
| `Core/Networking/Adapters/GroqAdapter.swift` | Groq-specific handling |
| `App/DependencyContainer.swift` | Simple DI container |
| `Features/Chat/ChatViewModel.swift` | Renamed from ViewModel.swift |

### Renaming Map

| Old Path | New Path |
|----------|----------|
| `TypelessOS/TypelessOS.swift` | `TypelessOS/App/TypelessOSApp.swift` |
| `TypelessOS/AppDelegate.swift` | `TypelessOS/App/AppDelegate.swift` |
| `TypelessOS/UI/Assistant/Api/Parts/ViewModel.swift` | `TypelessOS/Features/Chat/ChatViewModel.swift` |
| `TypelessOS/UI/Assistant/Api/UnifiedChatView.swift` | `TypelessOS/Features/Chat/ChatView.swift` |
| `TypelessOS/UI/Assistant/Api/AssistantApiView.swift` | `TypelessOS/Features/Chat/Components/AssistantContentView.swift` |
| `TypelessOS/UI/MainView.swift` | `TypelessOS/Features/MainView.swift` |
| `TypelessOS/UI/Terminal/Terminal.swift` | `TypelessOS/Features/Terminal/TerminalView.swift` |
| `TypelessOS/UI/Notepad/NotepadView.swift` | `TypelessOS/Features/Notepad/NotepadView.swift` |
| `TypelessOS/UI/Settings/SettingsContentView.swift` | `TypelessOS/Features/Settings/SettingsView.swift` |
| `TypelessOS/Utils/ChatHistoryManager.swift` | `TypelessOS/Core/Repositories/ChatRepository.swift` |
| `TypelessOS/Utils/NoteManager.swift` | `TypelessOS/Core/Repositories/NoteRepository.swift` |
| `TypelessOS/Utils/AuthManager.swift` | `TypelessOS/Core/Services/AuthService.swift` |
| `TypelessOS/Api/ChatApiProtocol.swift` | `TypelessOS/Core/Networking/ChatAPIProtocol.swift` |
| `TypelessOS/Api/GeminiApi.swift` | `TypelessOS/Core/Networking/Adapters/GeminiAdapter.swift` |
| `TypelessOS/Api/OpenAIApi.swift` | `TypelessOS/Core/Networking/Adapters/OpenAIAdapter.swift` |
| `TypelessOS/Api/GroqApi.swift` | `TypelessOS/Core/Networking/Adapters/GroqAdapter.swift` |
| `TypelessOS/Api/TerminalServerClient.swift` | `TypelessOS/Core/Networking/TerminalServerClient.swift` |
| `TypelessOS/Models/WhisperState.swift` | `TypelessOS/Core/Services/SpeechService.swift` |

### Files to Delete (Logic Merged)

| File | Reason |
|------|--------|
| `TypelessOS/UI/Assistant/Api/Parts/TerminalController.swift` | Merged into `TerminalService.swift` |
| `TypelessOS/Utils/Terminal/TerminalViewModel.swift` | Merged into `Features/Terminal/TerminalViewModel.swift` |
| `TypelessOS/Services/GoogleTasksService.swift` | Refactored into proper service pattern |

---

## Phase 4: Implementation Priority

### Week 1: Foundation
1. Create `DependencyContainer.swift`
2. Create `SettingsRepository.swift` (extract from Settings singleton)
3. Create `ChatRepository.swift` (extract from ChatHistoryManager)
4. Create `NoteRepository.swift` (extract from NoteManager)

### Week 2: Service Layer
1. Create `ChatService.swift` (extract from ViewModel)
2. Create `TerminalService.swift` (merge TerminalController + TerminalServerClient logic)
3. Create `SpeechService.swift` (extract from WhisperState)
4. Create `APIKeyService.swift`

### Week 3: API Consolidation
1. Create `ChatAPIClient.swift` with adapter pattern
2. Create `GeminiAdapter.swift`, `OpenAIAdapter.swift`, `GroqAdapter.swift`
3. Delete redundant API classes

### Week 4: ViewModel Migration
1. Rename `ViewModel.swift` → `ChatViewModel.swift`
2. Extract business logic to services
3. Create `TerminalViewModel.swift` (proper separation)
4. Create `SettingsViewModel.swift`

### Week 5: View Cleanup
1. Split `MainView.swift` into proper components
2. Ensure all views < 100 lines
3. Move reusable components to `Shared/Views/`
4. Final file reorganization

---

## Key Architectural Decisions

### 1. Dependency Injection
```swift
// DependencyContainer.swift
@MainActor
final class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()
    
    lazy var settingsRepository = SettingsRepository()
    lazy var chatRepository = ChatRepository()
    lazy var noteRepository = NoteRepository()
    
    lazy var apiKeyService = APIKeyService(settings: settingsRepository)
    lazy var chatAPIClient = ChatAPIClient(keyService: apiKeyService)
    lazy var terminalService = TerminalService()
    lazy var speechService = SpeechService()
    lazy var chatService = ChatService(
        api: chatAPIClient,
        repository: chatRepository,
        terminal: terminalService
    )
}
```

### 2. Unified API Client
```swift
// ChatAPIClient.swift
protocol ChatAPIAdapter {
    func buildRequest(messages: [Message], tools: [Tool]) throws -> URLRequest
    func parseResponse(data: Data) throws -> AsyncThrowingStream<String, Error>
}

class ChatAPIClient: ChatApiProtocol {
    private var currentAdapter: ChatAPIAdapter
    
    func switchProvider(_ provider: String) {
        currentAdapter = adapterFactory.create(for: provider)
    }
}
```

### 3. Repository Pattern
```swift
// ChatRepository.swift
protocol ChatRepositoryProtocol {
    func loadAll() async -> [SavedChat]
    func save(_ chat: SavedChat) async throws
    func delete(id: UUID) async throws
}

final class ChatRepository: ChatRepositoryProtocol {
    private let fileManager: FileManager
    private let directory: URL
    // Implementation...
}
```

---

Would you like me to begin implementing Phase 1 (Foundation) now? I'll start with:
1. `DependencyContainer.swift`
2. `SettingsRepository.swift`
3. `ChatRepository.swift`

---

**User:**

go ahead with phase 1

---

**Assistant:**

Starting Phase 1: Foundation. I'll create the core infrastructure files.

---
