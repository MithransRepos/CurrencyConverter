//
//  CurrencyConverterVC.swift
//  CurrencyConverter
//
//  Created by MithranN on 29/03/20.
//  Copyright © 2020 MithranN. All rights reserved.
//

import UIKit

class CurrencyConverterVC: BaseViewController {
    
    let currencyTextField: TextField = {
        let textField = TextField()
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = Padding.p2
        textField.textAlignment = .right
        return textField
    }()
   
    let currency: UIButton = {
        let button: UIButton = UIButton()
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.systemBlue, for: .selected)
        button.isSelected = false
        button.setTitle("Select currency", for: .normal)
        return button
    }()
    
    let dataSource: CurrencyConverterDS
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let vm = CurrencyConverterViewModel()
        dataSource = vm
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        vm.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Currency converter"
        currencyTextField.delegate = self
        currency.addTarget(self, action: #selector(openCurrencySelector), for: .touchUpInside)
        dataSource.getCurrencyExchangeRates()
    }
    
    override func addViews() {
        view.addSubview(currencyTextField)
        view.addSubview(currency)
        super.addViews()
    }

    override func setConstraints() {
        super.setConstraints()
        currencyTextField.set(.top(view, 100), .sameLeadingTrailing(view, Padding.p12), .height(44))
        currency.set(.trailing(view, Padding.p12), .below(currencyTextField, Padding.p12), .height(44), .width(150))
        tableView.set(.sameLeadingTrailing(view, Padding.p12), .below(currency, Padding.p12), .bottom(view))
    }
    
    override func setupTableView() {
        super.setupTableView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @objc func openCurrencySelector() {
        if dataSource.noOfExchangeRates == 0 { return }
        let currencySelector = CurrencySelectorVC(currencyList: dataSource.currencyListToSelect)
        currencySelector.delegate = self
        self.present(currencySelector, animated: true, completion: nil)
    }
    
}

extension CurrencyConverterVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        dataSource.didUserChangeAmount(amount: textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
   
}

extension CurrencyConverterVC: CurrencySelectorVCDelegate {
    func didSelectCurrenct(_ vc: CurrencySelectorVC, selectedIndex: Int, selectedText: String) {
        vc.dismiss(animated: true, completion: nil)
        currency.setTitle(selectedText, for: .normal)
        currency.isSelected = true
        dataSource.didUserSelectedCurrenct(at: selectedIndex)
    }
}

extension CurrencyConverterVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.noOfExchangeRates
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description()) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = dataSource.getCurrencyAt(indexPath.row)
        cell.selectionStyle = .none
        return cell
    }
    
}

extension CurrencyConverterVC: CurrencyConverterViewModelDelegate {
    func apiCallFailed() {
        let alert = UIAlertController(title: "Sorry couldn't fetch the exchange rates", message: "Please try again later", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}
