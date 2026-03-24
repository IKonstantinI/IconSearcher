import UIKit

final class StateView: UIView {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let messageFontSize: CGFloat = 17
        static let messageFontWeight: UIFont.Weight = .medium
        static let stackViewSpacing: CGFloat = 8
        static let layoutMargin: CGFloat = 20
    }
    
    // MARK: - Nested Types

    struct Configuration {
        let message: String
        let image: UIImage?
    }

    // MARK: - UI Elements

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: LayoutConstants.messageFontSize, weight: LayoutConstants.messageFontWeight)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, messageLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.stackViewSpacing
        stackView.alignment = .center
        return stackView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with config: Configuration) {
        messageLabel.text = config.message
        iconImageView.image = config.image
        iconImageView.isHidden = config.image == nil
    }
    
    func startLoading() {
        stackView.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        stackView.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        addSubview(stackView)
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: LayoutConstants.layoutMargin),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -LayoutConstants.layoutMargin),

            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
