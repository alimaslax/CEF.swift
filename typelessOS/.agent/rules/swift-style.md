---
description: Swift coding style and best practices for TypelessOS
alwaysApply: true
---

# Swift Coding Style

## General
- Swift 5+ modern syntax
- Prefer `let` over `var`
- Use type inference unless explicit types improve readability
- Meaningful, descriptive names following Swift API Design Guidelines

## SwiftUI Patterns
- Keep Views small and focused
- Extract reusable components
- Use property wrappers appropriately:
  - `@State`: Local view state
  - `@Binding`: Parent-child data flow
  - `@StateObject`: View-owned observables
  - `@ObservedObject`: Passed-in observables
  - `@EnvironmentObject`: App-wide shared state

## macOS-Specific
- `NSWindow`/`NSPanel` for custom window management
- `NSStatusItem` for menu bar integration
- `NSApp.activate(ignoringOtherApps:)` for window activation
- Handle window lifecycle and visibility correctly

## Code Organization
- Use `// MARK: -` to organize sections
- Properties at top of types
- Group lifecycle methods together
- Group action handlers together

## Error Handling
- Use `guard` for early returns
- Safe optional handling: `if let`, `guard let`, `??`
- Avoid force unwrapping (`!`)

## Async/Await
- Prefer async/await over completion handlers
- `@MainActor` for UI-related classes/structs
- Use `MainActor.run` for UI updates from async contexts
