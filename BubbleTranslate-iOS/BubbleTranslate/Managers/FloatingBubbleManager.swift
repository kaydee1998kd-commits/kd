import UIKit
import ObjectiveC

// MARK: - Floating Bubble Manager

/// Manages the floating bubble overlay that stays on top of all apps.
/// On jailbroken iOS, this window persists across app switches.
class FloatingBubbleManager {
    
    static let shared = FloatingBubbleManager()
    
    // The overlay window that contains our bubble
    private var overlayWindow: UIWindow?
    
    // The floating bubble view
    private var bubbleView: BubbleView?
    
    // The translation panel overlay
    private var translationWindow: UIWindow?
    private var translationPanel: TranslationPanelView?
    
    // State
    private(set) var isBubbleVisible = false
    private(set) var isTranslating = false
    private var isPanelVisible = false
    
    // Drag state
    private var bubbleInitialCenter: CGPoint = .zero
    private var dragStartPoint: CGPoint = .zero
    
    // Services
    private let ocrService = OCRService()
    private let translationService = TranslationService()
    
    // Timer for keeping the bubble alive
    private var keepAliveTimer: Timer?
    
    private init() {}
    
    // MARK: - Start / Stop
    
    func start() {
        createOverlayWindow()
        showBubble()
        startKeepAliveTimer()
    }
    
    func stop() {
        hideBubble()
        overlayWindow = nil
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
    }
    
    // MARK: - Create Overlay Window
    
    private func createOverlayWindow() {
        let screenBounds = UIScreen.main.bounds
        
        // Create the overlay window with maximum window level
        // On jailbroken iOS, this stays on top of ALL apps including SpringBoard
        let window = UIWindow.createOverlayWindow(frame: screenBounds)
        
        // Add a root view controller (required for iOS 13+)
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC
        
        self.overlayWindow = window
    }
    
    // MARK: - Show / Hide Bubble
    
    private func showBubble() {
        guard let window = overlayWindow else { return }
        
        // Calculate initial position (right side, middle of screen)
        let screenBounds = UIScreen.main.bounds
        let initialX = screenBounds.width - AppConfig.bubbleSize - AppConfig.bubbleEdgePadding
        let initialY = screenBounds.height / 2 - AppConfig.bubbleSize / 2
        
        let bubble = BubbleView(frame: CGRect(
            x: initialX,
            y: initialY,
            width: AppConfig.bubbleSize,
            height: AppConfig.bubbleSize
        ))
        
        // Add gesture recognizers
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bubbleTapped))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(bubbleDragged(_:)))
        
        bubble.addGestureRecognizer(tapGesture)
        bubble.addGestureRecognizer(panGesture)
        
        // Add to window
        window.addSubview(bubble)
        window.makeKeyAndVisible()
        window.isHidden = false
        
        self.bubbleView = bubble
        self.isBubbleVisible = true
        
        // Animate appearance
        bubble.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(
            withDuration: AppConfig.bubbleAppearAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            bubble.transform = .identity
        }
    }
    
    func hideBubble() {
        UIView.animate(
            withDuration: AppConfig.bubbleAppearAnimationDuration,
            animations: {
                self.bubbleView?.alpha = 0
                self.bubbleView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            },
            completion: { _ in
                self.bubbleView?.removeFromSuperview()
                self.bubbleView = nil
                self.isBubbleVisible = false
            }
        )
    }
    
    // MARK: - Keep Bubble Alive (Jailbreak)
    
    func keepBubbleAlive() {
        // Ensure overlay window stays visible when app goes to background
        overlayWindow?.isHidden = false
        overlayWindow?.alpha = 1.0
        
        // On jailbroken iOS, re-assert window level
        overlayWindow?.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }
    
    func restoreBubbleIfNeeded() {
        if overlayWindow == nil || bubbleView == nil {
            createOverlayWindow()
            showBubble()
        }
        overlayWindow?.isHidden = false
    }
    
    private func startKeepAliveTimer() {
        // Periodically ensure the bubble is visible
        keepAliveTimer = Timer.scheduledTimer(
            withTimeInterval: 5.0,
            repeats: true
        ) { [weak self] _ in
            self?.ensureBubbleVisible()
        }
    }
    
    private func ensureBubbleVisible() {
        guard isBubbleVisible else { return }
        overlayWindow?.isHidden = false
        overlayWindow?.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        
        // Force window to be key if needed
        if !(overlayWindow?.isKeyWindow ?? true) {
            // Don't make key if user is typing in another app
        }
    }
    
    // MARK: - Bubble Tap Action
    
    @objc private func bubbleTapped() {
        if isPanelVisible {
            hideTranslationPanel()
        } else {
            captureAndTranslate()
        }
    }
    
    // MARK: - Bubble Drag
    
    @objc private func bubbleDragged(_ gesture: UIPanGestureRecognizer) {
        guard let bubble = bubbleView else { return }
        
        let translation = gesture.translation(in: bubble.superview)
        let location = gesture.location(in: bubble.superview)
        
        switch gesture.state {
        case .began:
            bubbleInitialCenter = bubble.center
            dragStartPoint = location
            
            // Scale up slightly while dragging
            UIView.animate(withDuration: 0.15) {
                bubble.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
            
        case .changed:
            let newCenter = CGPoint(
                x: bubbleInitialCenter.x + translation.x,
                y: bubbleInitialCenter.y + translation.y
            )
            bubble.center = newCenter
            
        case .ended, .cancelled:
            // Scale back to normal
            UIView.animate(withDuration: 0.15) {
                bubble.transform = .identity
            }
            
            // Snap to nearest edge
            snapBubbleToEdge(bubble)
            
            // If barely moved, treat as tap
            let distance = hypot(
                location.x - dragStartPoint.x,
                location.y - dragStartPoint.y
            )
            if distance < 5 {
                bubbleTapped()
            }
            
        default:
            break
        }
    }
    
    private func snapBubbleToEdge(_ bubble: BubbleView) {
        let screenBounds = UIScreen.main.bounds
        let padding = AppConfig.bubbleEdgePadding
        let midX = screenBounds.width / 2
        
        // Determine which edge is closer
        let targetX: CGFloat
        if bubble.center.x < midX {
            targetX = padding + AppConfig.bubbleSize / 2
        } else {
            targetX = screenBounds.width - padding - AppConfig.bubbleSize / 2
        }
        
        // Clamp Y position
        let minY = padding + AppConfig.bubbleSize / 2 + 40 // Status bar
        let maxY = screenBounds.height - padding - AppConfig.bubbleSize / 2 - 40 // Home indicator
        let targetY = max(minY, min(maxY, bubble.center.y))
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            bubble.center = CGPoint(x: targetX, y: targetY)
        }
    }
    
    // MARK: - Capture & Translate
    
    private func captureAndTranslate() {
        guard !isTranslating else { return }
        isTranslating = true
        
        // Show loading state on bubble
        bubbleView?.setLoading(true)
        
        // Show translation panel immediately with loading state
        showTranslationPanel(loading: true)
        
        // Step 1: Capture the screen
        ocrService.captureScreen { [weak self] image in
            guard let self = self else { return }
            
            if let image = image {
                // Step 2: Perform OCR on the captured image
                self.ocrService.recognizeText(in: image) { [weak self] recognizedText in
                    guard let self = self else { return }
                    
                    if let text = recognizedText, !text.isEmpty {
                        // Step 3: Translate the recognized text
                        self.translateText(text)
                    } else {
                        // No text found
                        self.showTranslationResult(
                            original: "No Chinese text detected on screen",
                            translation: "Make sure Chinese text is visible and try again",
                            isError: true
                        )
                    }
                }
            } else {
                // Fallback: try pasteboard (clipboard)
                self.translateFromClipboard()
            }
        }
    }
    
    private func translateText(_ text: String) {
        translationService.translate(text: text) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.bubbleView?.setLoading(false)
                self.isTranslating = false
                
                switch result {
                case .success(let translationResult):
                    if let translation = translationResult.translation {
                        self.showTranslationResult(
                            original: text,
                            translation: translation
                        )
                    } else {
                        self.showTranslationResult(
                            original: text,
                            translation: translationResult.error ?? "Translation failed",
                            isError: true
                        )
                    }
                case .failure(let error):
                    self.showTranslationResult(
                        original: text,
                        translation: error.localizedDescription,
                        isError: true
                    )
                }
            }
        }
    }
    
    private func translateFromClipboard() {
        let clipboardText = UIPasteboard.general.string ?? ""
        
        if clipboardText.containsChinese {
            translateText(clipboardText)
        } else {
            DispatchQueue.main.async {
                self.bubbleView?.setLoading(false)
                self.isTranslating = false
                self.showTranslationResult(
                    original: "No text captured",
                    translation: "Could not read screen. Try copying Chinese text first, then tap the bubble.",
                    isError: true
                )
            }
        }
    }
    
    // MARK: - Translation Panel
    
    private func showTranslationPanel(loading: Bool = false) {
        guard !isPanelVisible else { return }
        
        let screenBounds = UIScreen.main.bounds
        let panelWidth = min(AppConfig.translationPanelWidth, screenBounds.width - 32)
        let panelHeight = loading ? 120 : AppConfig.translationPanelMaxHeight
        
        // Create a new window for the panel
        let panelWindow = UIWindow.createOverlayWindow(frame: screenBounds)
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        rootVC.view.isUserInteractionEnabled = true
        panelWindow.rootViewController = rootVC
        
        // Add tap-to-dismiss on background
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissPanelTapped))
        rootVC.view.addGestureRecognizer(dismissTap)
        
        // Create panel
        let panel = TranslationPanelView(frame: CGRect(
            x: (screenBounds.width - panelWidth) / 2,
            y: (screenBounds.height - panelHeight) / 2,
            width: panelWidth,
            height: panelHeight
        ))
        
        if loading {
            panel.setLoading(true)
        }
        
        rootVC.view.addSubview(panel)
        
        panelWindow.isHidden = false
        panelWindow.makeKeyAndVisible()
        
        self.translationWindow = panelWindow
        self.translationPanel = panel
        self.isPanelVisible = true
        
        // Animate in
        panel.alpha = 0
        panel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(
            withDuration: AppConfig.panelAppearAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: .curveEaseOut
        ) {
            panel.alpha = 1
            panel.transform = .identity
        }
    }
    
    private func showTranslationResult(original: String, translation: String, isError: Bool = false) {
        DispatchQueue.main.async {
            self.translationPanel?.setLoading(false)
            self.translationPanel?.displayResult(
                original: original,
                translation: translation,
                isError: isError
            )
            self.bubbleView?.setLoading(false)
            self.isTranslating = false
        }
    }
    
    @objc private func dismissPanelTapped() {
        hideTranslationPanel()
    }
    
    private func hideTranslationPanel() {
        guard isPanelVisible else { return }
        
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.translationPanel?.alpha = 0
                self.translationPanel?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { _ in
                self.translationWindow?.isHidden = true
                self.translationWindow = nil
                self.translationPanel = nil
                self.isPanelVisible = false
            }
        )
    }
}
