---
description: Build and run TypelessOS app
---

# Build and Run TypelessOS

// turbo-all

1. Build the project in Release configuration, kill any running instance, and launch the new build:

```bash
xcodebuild -project TypelessOS.xcodeproj -scheme TypelessOS -configuration Release build > /dev/null 2>&1 && \
killall TypelessOS 2>/dev/null; \
sleep 1; \
open ~/Library/Developer/Xcode/DerivedData/TypelessOS-*/Build/Products/Release/TypelessOS.app
```

Working directory: `/Users/mali/dev/typelessOS`

---

## Notes
- This command suppresses build output for cleaner logs
- If you need to debug build errors, remove `> /dev/null 2>&1`
- The `killall` command gracefully handles cases where the app isn't running
- The 1 second sleep ensures the old process is fully terminated
