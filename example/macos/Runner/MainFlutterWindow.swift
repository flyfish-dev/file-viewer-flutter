import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    title = "File Viewer"
    contentMinSize = NSSize(width: 420, height: 320)
    if !setFrameUsingName("FileViewerWorkspace") {
      let visibleFrame = screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? windowFrame
      setContentSize(NSSize(
        width: min(1100, visibleFrame.width * 0.88),
        height: min(760, visibleFrame.height * 0.85)
      ))
      center()
    }
    setFrameAutosaveName("FileViewerWorkspace")

    super.awakeFromNib()
  }
}
