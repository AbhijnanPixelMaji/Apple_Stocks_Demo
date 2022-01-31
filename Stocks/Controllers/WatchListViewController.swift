//
//  ViewController.swift
//  Stocks
//
//  Created by Abhijnan Maji on 12/08/21.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    
    private var panel: FloatingPanelController?
    
    ///Model
    //private var watchlistMap: [String: [String]] = [:]
    private var watchlistMap: [String: [CandleStick]] = [:]
    // ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        
        return table
    }()
    
//MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        fetchWatchListData()
        setUpTitleView()
        setUpFloatingPanel()
        //setUpChildView()
    }
    
//MARK: Private
    private func fetchWatchListData(){
        let symbols = PersistenceManager.shared.watchList
        let group = DispatchGroup()
        for symbol in symbols {
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result{
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        group.notify(queue: .main){[weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
        
    }
    
    private func createViewModels(){
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchlistMap{
            let changePercentage = getChangePercentage(for: candleSticks)
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "",
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: <#T##UIColor#>,
                    changePercentage: <#T##String#>)
            )
        }
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(for data: [CandleStick]) -> String{
        let today = Date()
        let priorDate = Date.addingTimeInterval(-(3600 * 24 * 2))
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String{
        guard let closingPrice = data.first?.close else{
            return ""
        }
        
        return "\(closingPrice)"
    }
    
    private func setupTableView(){
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpFloatingPanel(){
        let vc = NewsViewController(type: .topStories)
      //  let vc = NewsViewController(type: .compan(symbol: "APPLE"))
        let panel = FloatingPanelController()
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.delegate = self
    }
    
    private func setUpTitleView(){
        let titleView = UIView(
            frame: CGRect(x: 0,
                y: 0,
                width: view.width,
                height: navigationController?.navigationBar.height ?? 100
            )
        )
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width-20, height: titleView.height))
        label.text = "Stocks"
        navigationItem.titleView = titleView
        label.font = UIFont.systemFont(ofSize: 40, weight: .medium)
        titleView.addSubview(label)
    }
    

    
    private func setupSearchController(){
        let resultVC = SearchResultViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

extension WatchListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let quary = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchResultViewController,
              !quary.trimmingCharacters(in: .whitespaces).isEmpty else{
             return
        }
        //Reset Timer
        searchTimer?.invalidate()
        //Kickoff new timer
        //Optimize to reduce number of searches for when user stops typing
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            //Call API to Search
            APICaller.shared.search(query: quary) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        })
        
        //Update results controller
        print(quary)
    }
    
    
}

extension WatchListViewController: SearchResultsViewControllerDelegate{
    func searchResultViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
     // Present stock details for given selection
      let vc = StockDetailsViewController()
      let navVC = UINavigationController(rootViewController: vc)
      vc.title = searchResult.description
      present(navVC, animated: true)
    }
    
}

extension WatchListViewController: FloatingPanelControllerDelegate{
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
    
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
      //  Open details for selection
    }
}
