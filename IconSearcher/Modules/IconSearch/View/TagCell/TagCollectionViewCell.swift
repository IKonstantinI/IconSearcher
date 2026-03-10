import UIKit

final class TagCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TagCollectionViewCell"
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemGray
        contentView.layer.cornerRadius = 6
        
        contentView.addSubview(tagLabel)
        
        NSLayoutConstraint.activate([
           tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
           tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
           tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
           tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with text: String) {
        tagLabel.text = text
    }
}
