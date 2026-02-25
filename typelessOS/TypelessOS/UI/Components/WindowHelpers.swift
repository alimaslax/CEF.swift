import SwiftUI
import AppKit

/// A wrapper that makes its content a handle for dragging the window
struct WindowDragHandle<Content: View>: NSViewRepresentable {
    let content: Content
    let onTap: (() -> Void)?
    
    init(onTap: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.onTap = onTap
        self.content = content()
    }
    
    func makeNSView(context: Context) -> DraggableNSHostingView<Content> {
        let hostingView = DraggableNSHostingView(rootView: content)
        hostingView.onTap = onTap
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }
    
    func updateNSView(_ nsView: DraggableNSHostingView<Content>, context: Context) {
        nsView.rootView = content
        nsView.onTap = onTap
    }
}

class DraggableNSHostingView<Content: View>: NSHostingView<Content> {
    var onTap: (() -> Void)?
    private var mouseDownLocation: NSPoint?
    private var dragged = false

    override func mouseDown(with event: NSEvent) {
        mouseDownLocation = event.locationInWindow
        dragged = false
    }

    override func mouseDragged(with event: NSEvent) {
        guard let startLocation = mouseDownLocation else { return }
        let currentLocation = event.locationInWindow
        
        let deltaX = currentLocation.x - startLocation.x
        let deltaY = currentLocation.y - startLocation.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        if distance > 3 {
            dragged = true
            window?.performDrag(with: event)
        }
    }

    override func mouseUp(with event: NSEvent) {
        if !dragged {
            onTap?()
        }
        mouseDownLocation = nil
        dragged = false
    }
}

/// A 30px transparent area at the top of the window that allows dragging
struct TopDragArea: View {
    var body: some View {
        WindowDragHandle {
            Color.clear
                .contentShape(Rectangle())
        }
        .frame(height: 30)
    }
}
