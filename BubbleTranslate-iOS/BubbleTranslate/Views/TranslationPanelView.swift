import UIKit

// MARK: - Translation Panel View

/// Shows the translation result in a floating panel.
/// Displays original Chinese text and English translation.
class TranslationPanelView: UIView {
    
    // Subviews
    private let headerView = UIView()
    private let languageLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let originalLabel = UILabel()
    private let originalTextView = UITextView()
    private let arrowLabel = UILabel()
    private let translationLabel = UILabel()
    private let translationTextView = UITextView()
    private let actionStackView = UIStackView()
    private let copyButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    
    // State
    private var currentTranslation = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Panel styling
        backgroundColor = .panelBackground
        layer.cornerRadius = 20
        layer.borderColor = UIColor.panelBorder.cgColor
        layer.borderWidth = 1
        addShadow(opacity: 0.5, radius: 20)
        clipsToBounds = true
        
        // Header
        setupHeader()
        
        // Content
        setupContent()
        
        // Loading
        setupLoading()
    }
    
    private func setupHeader() {
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.03)
        addSubview(headerView)
        
        languageLabel.text = "中文 → English"
        languageLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        languageLabel.textColor = .panelAccent
        headerView.addSubview(languageLabel)
        
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.panelTextSecondary, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addSubview(closeButton)
    }
    
    private func setupContent() {
        // Original section label
        originalLabel.text = "DETECTED TEXT"
        originalLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        originalLabel.textColor = .panelTextMuted
        originalLabel.letterSpacing = 1.0
        addSubview(originalLabel)
        
        // Original text view
        originalTextView.isEditable = false
        originalTextView.isScrollEnabled = true
        originalTextView.backgroundColor = UIColor(white: 1, alpha: 0.05)
        originalTextView.layer.cornerRadius = 10
        originalTextView.font = UIFont.systemFont(ofSize: 14)
        originalTextView.textColor = .panelTextSecondary
        originalTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        addSubview(originalTextView)
        
        // Arrow
        arrowLabel.text = "↓"
        arrowLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        arrowLabel.textColor = .panelAccent
        arrowLabel.textAlignment = .center
        addSubview(arrowLabel)
        
        // Translation section label
        translationLabel.text = "TRANSLATION"
        translationLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        translationLabel.textColor = .panelAccent
        translationLabel.letterSpacing = 1.0
        addSubview(translationLabel)
        
        // Translation text view
        translationTextView.isEditable = false
        translationTextView.isScrollEnabled = true
        translationTextView.backgroundColor = UIColor.panelAccent.withAlphaComponent(0.1)
        translationTextView.layer.cornerRadius = 10
        translationTextView.layer.borderColor = UIColor.panelAccent.withAlphaComponent(0.3).cgColor
        translationTextView.layer.borderWidth = 1
        translationTextView.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        translationTextView.textColor = .panelTextPrimary
        translationTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        addSubview(translationTextView)
        
        // Action buttons
        actionStackView.axis = .horizontal
        actionStackView.spacing = 12
        actionStackView.distribution = .fillEqually
        addSubview(actionStackView)
        
        copyButton.setTitle("📋 Copy", for: .normal)
        copyButton.setTitleColor(.panelTextPrimary, for: .normal)
        copyButton.backgroundColor = UIColor(white: 1, alpha: 0.08)
        copyButton.layer.cornerRadius = 10
        copyButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        copyButton.addTarget(self, action: #selector(copyTranslation), for: .touchUpInside)
        actionStackView.addArrangedSubview(copyButton)
        
        speakButton.setTitle("🔊 Speak", for: .normal)
        speakButton.setTitleColor(.panelTextPrimary, for: .normal)
        speakButton.backgroundColor = UIColor(white: 1, alpha: 0.08)
        speakButton.layer.cornerRadius = 10
        speakButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        speakButton.addTarget(self, action: #selector(speakTranslation), for: .touchUpInside)
        actionStackView.addArrangedSubview(speakButton)
    }
    
    private func setupLoading() {
        loadingView.color = .panelAccent
        loadingView.hidesWhenStopped = true
        addSubview(loadingView)
        
        loadingLabel.text = "Capturing & Translating..."
        loadingLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        loadingLabel.textColor = .panelTextSecondary
        loadingLabel.textAlignment = .center
        loadingLabel.isHidden = true
        addSubview(loadingLabel)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 16
        let contentWidth = bounds.width - padding * 2
        var yOffset: CGFloat = padding
        
        // Header
        headerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
        languageLabel.frame = CGRect(x: padding, y: 12, width: 150, height: 20)
        closeButton.frame = CGRect(x: bounds.width - 44, y: 8, width: 36, height: 28)
        
        yOffset = 52
        
        // Check if loading
        if loadingView.isAnimating {
            loadingView.center = CGPoint(x: bounds.midX, y: bounds.midY - 10)
            loadingLabel.frame = CGRect(x: padding, y: bounds.midY + 15, width: contentWidth, height: 20)
            return
        }
        
        // Original section
        originalLabel.frame = CGRect(x: padding, y: yOffset, width: contentWidth, height: 16)
        yOffset += 20
        
        let originalHeight: CGFloat = min(originalTextView.contentSize.height + 20, 80)
        originalTextView.frame = CGRect(x: padding, y: yOffset, width: contentWidth, height: originalHeight)
        yOffset += originalHeight + 8
        
        // Arrow
        arrowLabel.frame = CGRect(x: padding, y: yOffset, width: contentWidth, height: 24)
        yOffset += 28
        
        // Translation section
        translationLabel.frame = CGRect(x: padding, y: yOffset, width: contentWidth, height: 16)
        yOffset += 20
        
        let remainingHeight = bounds.height - yOffset - 56 - padding
        let translationHeight = max(min(translationTextView.contentSize.height + 20, remainingHeight), 60)
        translationTextView.frame = CGRect(x: padding, y: yOffset, width: contentWidth, height: translationHeight)
        yOffset += translationHeight + 12
        
        // Action buttons
        actionStackView.frame = CGRect(x: padding, y: yOffset, width: contentWidth, height: 40)
    }
    
    // MARK: - State Management
    
    func setLoading(_ loading: Bool) {
        if loading {
            loadingView.startAnimating()
            loadingLabel.isHidden = false
            
            // Hide content
            originalLabel.isHidden = true
            originalTextView.isHidden = true
            arrowLabel.isHidden = true
            translationLabel.isHidden = true
            translationTextView.isHidden = true
            actionStackView.isHidden = true
        } else {
            loadingView.stopAnimating()
            loadingLabel.isHidden = true
            
            // Show content
            originalLabel.isHidden = false
            originalTextView.isHidden = false
            arrowLabel.isHidden = false
            translationLabel.isHidden = false
            translationTextView.isHidden = false
            actionStackView.isHidden = false
        }
        
        setNeedsLayout()
    }
    
    func displayResult(original: String, translation: String, isError: Bool = false) {
        originalTextView.text = original
        translationTextView.text = translation
        currentTranslation = translation
        
        if isError {
            translationTextView.textColor = UIColor.systemRed.withAlphaComponent(0.8)
            translationTextView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            translationTextView.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.3).cgColor
        } else {
            translationTextView.textColor = .panelTextPrimary
            translationTextView.backgroundColor = UIColor.panelAccent.withAlphaComponent(0.1)
            translationTextView.layer.borderColor = UIColor.panelAccent.withAlphaComponent(0.3).cgColor
        }
        
        // Adjust frame height based on content
        adjustHeight()
        setLoading(false)
    }
    
    private func adjustHeight() {
        let padding: CGFloat = 16
        let contentWidth = bounds.width - padding * 2
        
        // Calculate required height
        let originalSize = originalTextView.sizeThatFits(CGSize(width: contentWidth - 24, height: .greatestFiniteMagnitude))
        let translationSize = translationTextView.sizeThatFits(CGSize(width: contentWidth - 24, height: .greatestFiniteMagnitude))
        
        var totalHeight: CGFloat = padding // top padding
        totalHeight += 44 // header
        totalHeight += 20 + min(originalSize.height + 20, 80) // original
        totalHeight += 8 + 24 + 28 // arrow
        totalHeight += 20 + min(translationSize.height + 20, 200) // translation
        totalHeight += 12 + 40 // action buttons
        totalHeight += padding // bottom padding
        
        let newHeight = max(min(totalHeight, AppConfig.translationPanelMaxHeight), 200)
        
        UIView.animate(withDuration: 0.2) {
            self.frame.size.height = newHeight
            self.frame.origin.y = (UIScreen.main.bounds.height - newHeight) / 2
        }
    }
    
    // MARK: - Actions
    
    @objc private func copyTranslation() {
        UIPasteboard.general.string = currentTranslation
        
        // Brief visual feedback
        copyButton.setTitle("✓ Copied!", for: .normal)
        copyButton.setTitleColor(.systemGreen, for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.copyButton.setTitle("📋 Copy", for: .normal)
            self.copyButton.setTitleColor(.panelTextPrimary, for: .normal)
        }
    }
    
    @objc private func speakTranslation() {
        let synth = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: currentTranslation)
        utterance.language = "en-US"
        utterance.rate = 0.9
        synth.speak(utterance)
    }
}

// MARK: - UILabel letter spacing

private extension UILabel {
    var letterSpacing: CGFloat {
        get { return 0 }
        set {
            guard let text = self.text else { return }
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(
                .kern,
                value: newValue,
                range: NSRange(location: 0, length: attributedString.length)
            )
            attributedString.addAttribute(
                .foregroundColor,
                value: textColor ?? .white,
                range: NSRange(location: 0, length: attributedString.length)
            )
            attributedText = attributedString
        }
    }
}

import AVFoundation
