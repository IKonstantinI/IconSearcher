import UIKit

final class NotificationHUDView: UIView {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let imageSize: CGFloat = 50
        static let fontSize: CGFloat = 15
        static let stackViewSpacing: CGFloat = 8
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 16
        static let backgroundAlpha: CGFloat = 0.7
    }

    // MARK: - UI Elements

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: LayoutConstants.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: LayoutConstants.imageSize)
        ])
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: LayoutConstants.fontSize, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.stackViewSpacing
        stackView.alignment = .center
        return stackView
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

    func configure(with image: UIImage?, text: String) {
        self.imageView.image = image
        self.messageLabel.text = text
    }

    // MARK: - Setup UI

    private func setupUI() {
        backgroundColor = UIColor(white: 0, alpha: LayoutConstants.backgroundAlpha)
        layer.cornerRadius = LayoutConstants.cornerRadius
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: LayoutConstants.padding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: LayoutConstants.padding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -LayoutConstants.padding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -LayoutConstants.padding)
        ])
    }
}
