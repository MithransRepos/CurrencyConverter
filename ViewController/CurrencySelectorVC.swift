//
//  CurrencySelectorVC.swift
//  CurrencyConverter
//
//  Created by MithranN on 29/03/20.
//  Copyright © 2020 MithranN. All rights reserved.
//

import UIKit

protocol CurrencySelectorVCDelegate: class {
    func didSelectCurrenct(_ vc: CurrencySelectorVC, selectedIndex: Int, selectedText: String)
}

class CurrencySelectorVC: BaseViewController {
    
    let currencyList: [String]
    
    weak var delegate: CurrencySelectorVCDelegate?
    
    init(currencyList: [String]) {
        self.currencyList = currencyList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupTableView() {
        super.setupTableView()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
    }
    
    override func setConstraints() {
        super.setConstraints()
        tableView.set(.fillSuperView(view))
    }
    
}
extension CurrencySelectorVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description()) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = currencyList[safeIndex: indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedText: String = currencyList[safeIndex: indexPath.row] else {
            return
        }
        delegate?.didSelectCurrenct(self, selectedIndex: indexPath.row, selectedText: selectedText)
    }
    
}
