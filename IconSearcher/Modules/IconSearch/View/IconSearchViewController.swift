import UIKit

final class IconSearchViewController: UIViewController, UITableViewDelegate {
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private var icons: [IconViewModel] = []
    
    var presenter: IconSearchPresenterProtocol?
    
    init(presenter: IconSearchPresenterProtocol?) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Icon Searcher"
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.register(IconTableViewCell.self, forCellReuseIdentifier: "IconCell")
        tableView.rowHeight = 60
    }
}

extension IconSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath) as? IconTableViewCell else {
            return UITableViewCell()
        }
        
        let icon = icons[indexPath.row]
        
        let cellPresenter = IconCellPresenter()
        cell.configure(with: icon, presenter: cellPresenter)
        
        return cell
    }
}

extension IconSearchViewController: IconSearchViewProtocol {
    func showIcons(viewModels: [IconViewModel]) {
        self.icons = viewModels
        self.tableView.reloadData()
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension IconSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter?.searchButtonTapped(query: searchBar.text)
        view.endEditing(true)
    }
}

extension IconSearchViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectIcon(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == icons.count - 9 {
            presenter?.scrolledToButtom()
        }
    }
}
