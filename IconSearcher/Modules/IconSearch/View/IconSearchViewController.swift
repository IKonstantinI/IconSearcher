import UIKit

final class IconSearchViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - UI Elements
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    private lazy var stateView: StateView = {
        let view = StateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - Properties
    
    private var viewModels: [IconViewModel] = []
    
    var presenter: IconSearchPresenterProtocol?
    
    // MARK: - Initialization
    
    init(presenter: IconSearchPresenterProtocol?) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Icon Searcher"
        
        view.addSubview(stateView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(IconTableViewCell.self, forCellReuseIdentifier: "IconCell")
        view.addSubview(tableView)
        
        
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stateView.topAnchor.constraint(equalTo: self.view.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension IconSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath) as? IconTableViewCell else {
            return UITableViewCell()
        }
        
        let icon = viewModels[indexPath.row]
        cell.configure(with: icon)
        return cell
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension IconSearchViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { viewModels[$0.row].iconImageURL }
        urls.forEach { ImageLoader.shared.loadImage(from: $0) { _ in } }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { viewModels[$0.row].iconImageURL }
        urls.forEach { ImageLoader.shared.cancelLoad(for: $0)}
    }
}

// MARK: - UITableViewDelegate

extension IconSearchViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectIcon(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModels.count - 8 {
            presenter?.scrolledToBottom()
        }
    }
}

// MARK: - IconSearchViewProtocol

extension IconSearchViewController: IconSearchViewProtocol {
    
    func showIcons(viewModels: [IconViewModel]) {
        self.viewModels = viewModels
        self.tableView.reloadData()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
    }
    
    func render(state: ScreenState) {
        switch state {
        case .empty:
            tableView.isHidden = true
            stateView.isHidden = false
            stateView.stopLoading()
            stateView.configure(
                with: .init(message: "Enter a query to search for icons", image: UIImage(systemName: "keyboard"))
            )
            
        case .noResult:
            tableView.isHidden = true
            stateView.isHidden = false
            stateView.stopLoading()
            stateView.configure(
                with: .init(message: "Not found", image: UIImage(systemName: "magnifyingglass.circle"))
            )
            
        case .loading:
            tableView.isHidden = true
            stateView.isHidden = false
            stateView.startLoading()
            
        case .showingContent:
            tableView.isHidden = false
            stateView.isHidden = true
            stateView.stopLoading()
            
        case .error(let message):
            tableView.isHidden = true
            stateView.isHidden = false
            stateView.stopLoading()
            stateView.configure(
                with: .init(message: message, image: UIImage(systemName: "xmark.octagon"))
            )
        }
    }
}

// MARK: - UISearchBarDelegate

extension IconSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter?.searchButtonTapped(query: searchBar.text)
        view.endEditing(true)
    }
}

