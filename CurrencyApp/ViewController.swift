//
//  ViewController.swift
//  CurrencyApp
//
//  Created by Leonardo Reis on 14/03/19.
//  Copyright © 2019 Leonardo Reis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var currencies: [Currency] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Currencies"
        tableView.dataSource = self
        tableView.delegate = self
        //        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(requestCurrencies), userInfo: nil, repeats: true)
        
        requestCurrencies()
    }
}

// MARK: - Request

extension ViewController {
    func loadDataWithURL(_ url: URL?, completion: @escaping (_ results: [Currency]?, _ error: Error?) -> ()) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        if let url = url {
            session.dataTask(with: url, completionHandler: { (response, data, error) in
                DispatchQueue.main.async(execute: { () -> Void in
                    if error != nil {
                        completion(nil, error)
                    } else if let response = response {
                        do {
                            if let json = try? JSONSerialization.jsonObject(with: response, options: []) {
                                if let jsonDict = json as? [String: Any] {
                                    if let ratesDict = jsonDict["rates"] as? [String: Any] {
                                        let dicts = ratesDict.map({(key, value) -> [String: Any]? in
                                            let dict = ["name" : key,
                                                        "value": value]
                                            return dict
                                        })
                                        
                                        let data = try JSONSerialization.data(withJSONObject: dicts, options: .prettyPrinted)
                                        let currencies = try JSONDecoder().decode([Currency].self, from: data)
                                        
                                        completion(currencies, nil)
                                    }
                                }
                            }
                        } catch( let error) {
                            print(error)
                        }
                    } else {
                        completion(nil, NSError(domain: "ErrorDomain", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Couldn't load Data"]))
                    }
                    session.finishTasksAndInvalidate()
                })
            }).resume()
        } else {
            completion(nil, NSError(domain: "ErrorDomain", code: -2, userInfo: [ NSLocalizedDescriptionKey: "Data URL not found."]))
        }
    }
    
    @objc func requestCurrencies() {
        let url = URL(string: "https://revolut.duckdns.org/latest?base=EUR")
        loadDataWithURL(url) { (results, error) in
            if let resultsDict = results {
                self.currencies = resultsDict
                self.tableView.reloadData()
            } else {
                let alertController = UIAlertController(title: "Error", message: "Sorry! There was an error!!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                let reloadAction = UIAlertAction(title: "Fetch", style: .default, handler: { (action) in
                    self.requestCurrencies()
                })
                alertController.addAction(okAction)
                alertController.addAction(reloadAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Table view data source

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currency = currencies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
        cell.textLabel?.text = currency.name
        let textField = UITextField(frame: CGRect(x: 110, y: 10, width: 185, height: 30))
        textField.delegate = self
        textField.text = "\(currency.value)"
        
        cell.accessoryView = textField
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let currency = currencies[sourceIndexPath.row]
        currencies.insert(currency, at: destinationIndexPath.row)
    }
}

// MARK: - UITextField delegate

extension ViewController: UITextFieldDelegate {
    fileprivate func dictToCurrency(_ newCurrencyDict: [String : Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: newCurrencyDict, options: .prettyPrinted)
            let newCurrency = try JSONDecoder().decode(Currency.self, from: data)
        } catch (let err) {
            print(err)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let value = NSNumber(pointer: textField.text)
        let floatValue = value.doubleValue
        
        self.currencies = currencies.map{
            let newCurrencyDict = ["name": $0.name,
                                   "value": ($0.value * floatValue)] as [String : Any]
            dictToCurrency(newCurrencyDict)
        }
        
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}


