import UIKit

// MARK: - Bubble View

/// The floating bubble button that stays on screen.
/// Draggable, tappable, with a gradient design and loading state.
class BubbleView: UIView {
    
    // Subviews
    private let iconLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let pulseLayer = CAShapeLayer()
    
    // State
    private var isLoading = false
    private var pulseAnimation: CABasicAnimation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Background
        backgroundColor = .clear
        layer.cornerRadius = AppConfig.bubbleCornerRadius
        clipsToBounds = false
        
        // Gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.bubbleGradientStart.cgColor,
            UIColor.bubbleGradientEnd.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = AppConfig.bubbleCornerRadius
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Shadow
        addShadow(
            color: UIColor.bubbleGradientStart,
            opacity: 0.4,
            offset: CGSize(width: 0, height: 4),
            radius: 12
        )
        
        // Border glow
        layer.borderColor = UIColor(white: 1, alpha: 0.3).cgColor
        layer.borderWidth = 1.5
        
        // Icon label - show 中/EN
        iconLabel.text = "中→A"
        iconLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        iconLabel.textColor = .white
        iconLabel.textAlignment = .center
        iconLabel.numberOfLines = 2
        addSubview(iconLabel)
        
        // Activity indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        addSubview(activityIndicator)
        
        // Setup pulse layer
        setupPulseLayer()
    }
    
    private func setupPulseLayer() {
        pulseLayer.fillColor = UIColor.bubbleGradientStart.cgColor
        pulseLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: -4, dy: -4)).cgPath
        pulseLayer.opacity = 0
        pulseLayer.frame = bounds.insetBy(dx: -4, dy: -4)
        layer.insertSublayer(pulseLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
        
        // Layout icon
        iconLabel.frame = bounds
        
        // Layout activity indicator
        activityIndicator.center = center
        activityIndicator.frame.origin.x = bounds.midX - activityIndicator.frame.width / 2
        activityIndicator.frame.origin.y = bounds.midY - activityIndicator.frame.height / 2
    }
    
    // MARK: - Loading State
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
        
        if loading {
            iconLabel.isHidden = true
            activityIndicator.startAnimating()
            startPulseAnimation()
        } else {
            iconLabel.isHidden = false
            activityIndicator.stopAnimating()
            stopPulseAnimation()
        }
    }
    
    private func startPulseAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.4
        animation.toValue = 0
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.autoreverses = true
        pulseLayer.add(animation, forKey: "pulse")
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.3
        scaleAnimation.duration = 1.0
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.autoreverses = true
        pulseLayer.add(scaleAnimation, forKey: "pulseScale")
    }
    
    private func stopPulseAnimation() {
        pulseLayer.removeAllAnimations()
        pulseLayer.opacity = 0
    }
}
