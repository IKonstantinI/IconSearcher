import UIKit

final class IconTableViewCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let sizeLabel = UILabel()
    private let tagsLabel = UILabel()
    
    private var cellPresenter: (any IconCellPresenterProtocol)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(tagsLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 48),
            iconImageView.heightAnchor.constraint(equalToConstant: 48),
            
            sizeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            sizeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tagsLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            tagsLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 4),
            tagsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tagsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        iconImageView.contentMode = .scaleAspectFit
        tagsLabel.font = .systemFont(ofSize: 12)
        tagsLabel.textColor = .gray
    }
    
    func configure(with viewModel: IconViewModel, presenter: IconCellPresenterProtocol) {
        self.cellPresenter = presenter
        
        sizeLabel.text = viewModel.sizeText
        tagsLabel.text = viewModel.tagsText
        
        presenter.loadImage(from: viewModel.iconImageURL, to: iconImageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        cellPresenter?.cancelLoad()
        cellPresenter = nil
    }
}
