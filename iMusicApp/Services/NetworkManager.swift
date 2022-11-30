//
//  NetworkManager.swift
//  iMusicApp
//
//  Created by Артём on 26.11.2022.
//

import Foundation
import Alamofire

class NetworkManager {
    
    func fetchData(searchText: String, completion: @escaping (SearchResponse?)->Void) {
        let url = "https://itunes.apple.com/search"
        let params = ["term": "\(searchText)", "limit": "50", "media": "music"]
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default).responseData { dataResponse in
            if let error = dataResponse.error {
                print("Error \(error.localizedDescription)")
                completion(nil)
            }
            guard let data = dataResponse.data else {return}
            do {
                let tracks = try JSONDecoder().decode(SearchResponse.self, from: data)
                print("result", tracks)
                completion(tracks)
            } catch let decodingError {
                print("Decoding error", decodingError.localizedDescription)
                completion(nil)
            }
            
        }
    }
}
