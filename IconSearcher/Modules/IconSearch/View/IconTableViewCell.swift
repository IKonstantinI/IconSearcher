import UIKit

final class IconTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let thumbnailSize: CGFloat = 60
        static let cellPadding: CGFloat = 16
        static let horizontalSpacing: CGFloat = 12
        static let verticalSpacing: CGFloat = 4
    }
    
    private enum StyleConstants {
        static let titleFontSize: CGFloat = 17
        static let titleFontWeight: UIFont.Weight = .semibold
        static let subtitleFontSize: CGFloat = 14
    }

    // MARK: - UI Elements

    private let iconImageView = UIImageView()
    private let sizeLabel = UILabel()
    private let tagsLabel = UILabel()

    private var iconURL: URL?
    private let imageLoader: ImageLoader?

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.imageLoader = ServiceAssembly.makeImageLoader()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupUI() {
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(tagsLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        sizeLabel.font = .systemFont(ofSize: StyleConstants.titleFontSize, weight: StyleConstants.titleFontWeight)
        sizeLabel.textColor = .label
        
        tagsLabel.font = .systemFont(ofSize: StyleConstants.subtitleFontSize)
        tagsLabel.textColor = .secondaryLabel
        tagsLabel.numberOfLines = 0
        
        iconImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LayoutConstants.cellPadding),
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.cellPadding),
            iconImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.thumbnailSize),
            iconImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.thumbnailSize),
            iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -LayoutConstants.cellPadding),
                
            sizeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: LayoutConstants.horizontalSpacing),
            sizeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.cellPadding),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.cellPadding),
                
            tagsLabel.leadingAnchor.constraint(equalTo: sizeLabel.leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: sizeLabel.trailingAnchor),
            tagsLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: LayoutConstants.verticalSpacing),
            tagsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -LayoutConstants.cellPadding)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with viewModel: IconViewModel) {
        
        sizeLabel.text = viewModel.sizeText
        tagsLabel.text = viewModel.tags.map { "#\($0)" }.joined(separator: " ")
        
        self.iconURL = viewModel.iconImageURL
        self.iconImageView.image = nil
        
        if let url = self.iconURL {
            imageLoader?.loadImage(from: url) { [weak self] image in
                guard let self = self, self.iconURL == url else {
                    return
                }
                self.iconImageView.image = image
            }
        }
    }

    // MARK: - Cell Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        iconImageView.image = nil
        sizeLabel.text = nil
        tagsLabel.text = nil

        if let iconURL = self.iconURL {
            imageLoader?.cancelLoad(for: iconURL)
        }
        self.iconURL = nil
    }
}
