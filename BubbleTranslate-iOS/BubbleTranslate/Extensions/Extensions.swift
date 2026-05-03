import UIKit

// MARK: - UIWindow Extension for Overlay

extension UIWindow {
    
    /// Create an overlay window that stays on top of ALL apps (jailbroken iOS)
    static func createOverlayWindow(frame: CGRect) -> UIWindow {
        let window = UIWindow(frame: frame)
        
        // Use the highest possible window level to stay on top
        // On jailbroken iOS, this works across all apps
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        
        // Make it transparent and non-opaque
        window.backgroundColor = .clear
        window.isOpaque = false
        
        // Don't intercept touches outside our views
        window.isUserInteractionEnabled = true
        
        // Prevent the window from being captured in screenshots (optional)
        // window.isSecureTextEntry = false
        
        return window
    }
}

// MARK: - UIColor Extension

extension UIColor {
    static let bubbleGradientStart = UIColor(red: 0.39, green: 0.40, blue: 0.95, alpha: 1.0)
    static let bubbleGradientEnd = UIColor(red: 0.58, green: 0.34, blue: 0.93, alpha: 1.0)
    static let panelBackground = UIColor(red: 0.06, green: 0.07, blue: 0.11, alpha: 0.95)
    static let panelBorder = UIColor(white: 1.0, alpha: 0.1)
    static let panelAccent = UIColor(red: 0.39, green: 0.40, blue: 0.95, alpha: 1.0)
    static let panelTextPrimary = UIColor.white
    static let panelTextSecondary = UIColor(white: 1.0, alpha: 0.6)
    static let panelTextMuted = UIColor(white: 1.0, alpha: 0.4)
}

// MARK: - String Extension

extension String {
    /// Check if string contains Chinese characters
    var containsChinese: Bool {
        let range = self.range(of: "\\p{Han}", options: .regularExpression)
        return range != nil
    }
    
    /// Truncate string for display
    func truncated(to length: Int) -> String {
        if self.count <= length { return self }
        return String(self.prefix(length)) + "..."
    }
}

// MARK: - UIView Extension

extension UIView {
    func addShadow(
        color: UIColor = .black,
        opacity: Float = 0.3,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 8
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    func addGradient(
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 1)
    ) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
}
