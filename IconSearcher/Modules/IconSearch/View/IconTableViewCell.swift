import UIKit

final class IconTableViewCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let sizeLabel = UILabel()
    
    private var tags: [String] = []
    private var tagsCollectionView: UICollectionView!
    
    private var cellPresenter: (any IconCellPresenterProtocol)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        tagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagsCollectionView.backgroundColor = .clear
        tagsCollectionView.showsHorizontalScrollIndicator = false
        
        tagsCollectionView.dataSource = self
        
        tagsCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.reuseIdentifier)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(tagsCollectionView)
        
        sizeLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        sizeLabel.textColor = .label
        iconImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
                
            sizeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            sizeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
            tagsCollectionView.leadingAnchor.constraint(equalTo: sizeLabel.leadingAnchor),
            tagsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tagsCollectionView.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 8),
            tagsCollectionView.heightAnchor.constraint(equalToConstant: 28),
            tagsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with viewModel: IconViewModel, presenter: IconCellPresenterProtocol) {
        self.cellPresenter = presenter
        
        sizeLabel.text = viewModel.sizeText
        tagsLabel.text = viewModel.tags
        
        presenter.loadImage(from: viewModel.iconImageURL, to: iconImageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        (cellPresenter as? IconCellPresenter)?.cancleOngoingLoad()
        cellPresenter = nil
    }
}

extension IconTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TagCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? TagCollectionViewCell else {
            fatalError("Could not dequeue TagCollectionViewCell")
        }
        
        let tagName = tags[indexPath.item]
        
        cell.configure(with: tagName)
        
        return cell
    }
    
    
}
