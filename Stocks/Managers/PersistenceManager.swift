//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Abhijnan Maji on 12/08/21.
//

import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants{
        static let onBordedKey = "hasOnboarded"
        static let watchlistKey = "watchList"
    }
    private init() {}
    
    //MARK:- Public
    
    public var watchList: [String]{
        if !hasOnboarded {
            userDefaults.set(true, forKey: Constants.onBordedKey)
           setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    
    public func addToWatchList(){
        
    }
    
    public func removeFromWatchList(){
        
    }
    
    //MARK:- Private
  
    private var hasOnboarded: Bool{
        return userDefaults.bool(forKey: Constants.onBordedKey)
    }
    
    private func setUpDefaults(){
        let map: [String:String] = [
            "AAPL": "Apple Inc.",
            "MSFT": "Microsoft Corporation.",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet.",
            "AMZN": "Amazon.com, Inc.",
            "WORK": "Slack Technologies.",
            "FB": "Facebook Inc.",
            "NVDA": "Nvdia Inc.",
            "NKE": "Nike.",
            "PINS": "Pinterest Inc."
        ]
        
        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)
        
        for(symbol, name) in map{
            userDefaults.set(name, forKey: symbol)
        }
    }
}
