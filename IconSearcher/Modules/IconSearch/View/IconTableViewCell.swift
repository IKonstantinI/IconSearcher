import UIKit

final class IconTableViewCell: UITableViewCell {
    
    //MARK: - UI Elements
    
    private let iconImageView = UIImageView()
    private let sizeLabel = UILabel()
    private let tagsLabel = UILabel()
    
    private var iconURL: URL?
    
    //MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(tagsLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        sizeLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        sizeLabel.textColor = .label
        
        tagsLabel.font = .systemFont(ofSize: 14)
        tagsLabel.textColor = .secondaryLabel
        tagsLabel.numberOfLines = 0
        
        iconImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
                
            sizeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            sizeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
            tagsLabel.leadingAnchor.constraint(equalTo: sizeLabel.leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: sizeLabel.trailingAnchor),
            tagsLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 4),
            tagsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    //MARK: - Configuration
    
    func configure(with viewModel: IconViewModel) {
        
        sizeLabel.text = viewModel.sizeText
        tagsLabel.text = viewModel.tags.map { "#\($0)" }.joined(separator: " ")
        
        self.iconURL = viewModel.iconImageURL
        self.iconImageView.image = nil
        
        if let url = self.iconURL {
            ImageLoader.shared.loadImage(from: url) { [weak self] image in
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
        iconImageView.image = nil
        
        if let iconURL = self.iconURL {
            ImageLoader.shared.cancelLoad(for: iconURL)
        }
        self.iconURL = nil
    }
}
