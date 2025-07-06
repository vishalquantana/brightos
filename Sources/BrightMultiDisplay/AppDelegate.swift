import Cocoa
import SwiftUI
import CoreGraphics
import KeyboardShortcuts

class PixelWindow: NSWindow {
    init(screen: NSScreen) {
        let screenFrame = screen.frame
        let rect = NSRect(x: screenFrame.origin.x,
                          y: screenFrame.origin.y + screenFrame.height - 1,
                          width: 1, height: 1)
        super.init(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
        self.isOpaque = false
        self.backgroundColor = .white
        self.level = .statusBar
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.alphaValue = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() { self.orderFront(nil) }
    func hide() { self.orderOut(nil) }
}

func applyGamma(to display: CGDirectDisplayID, gamma: Float) {
    let tableSize = 256
    var red = [CGGammaValue](repeating: 0, count: tableSize)
    var green = red
    var blue = red

    for i in 0..<tableSize {
        let value = powf(Float(i) / Float(tableSize - 1), 1.0 / gamma)
        red[i] = value
        green[i] = value
        blue[i] = value
    }

    CGSetDisplayTransferByTable(display, UInt32(tableSize), &red, &green, &blue)
}

func applyGammaToAllDisplays(_ gamma: Float) {
    let maxDisplays: UInt32 = 16
    var displayCount: UInt32 = 0
    var displays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))

    if CGGetActiveDisplayList(maxDisplays, &displays, &displayCount) == .success {
        for i in 0..<displayCount {
            applyGamma(to: displays[Int(i)], gamma: gamma)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var pixelWindows: [PixelWindow] = []
    var isActive = false
    let defaultGamma: Float = 1.0
    let boostedGamma: Float = 1.5
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.title = "☀️"
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle Boost", action: #selector(toggle), keyEquivalent: "b"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu

        KeyboardShortcuts.onKeyUp(for: .toggleShortcut) {
            self.toggle()
        }
    }

    @objc func toggle() {
        isActive.toggle()
        if isActive {
            activateOverlay()
        } else {
            deactivateOverlay()
        }
    }

    func activateOverlay() {
        pixelWindows = NSScreen.screens.map { PixelWindow(screen: $0) }
        pixelWindows.forEach { $0.show() }
        applyGammaToAllDisplays(boostedGamma)
    }

    func deactivateOverlay() {
        pixelWindows.forEach { $0.hide() }
        pixelWindows.removeAll()
        applyGammaToAllDisplays(defaultGamma)
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

extension KeyboardShortcuts.Name {
    static let toggleShortcut = Self("toggleShortcut")
}
