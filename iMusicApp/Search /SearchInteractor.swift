//
//  SearchInteractor.swift
//  iMusicApp
//
//  Created by Артём on 26.11.2022.


import UIKit

protocol SearchBusinessLogic {
    func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    
    var presenter: SearchPresentationLogic?
    var service: SearchService?
    let networkFetcher = NetworkManager()
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        if service == nil {
            service = SearchService()
        }
        
        switch request {
        
        case .getTracks(let searchTerm):
            presenter?.presentData(response: .presentFooterView)
            networkFetcher.fetchData(searchText: searchTerm) { [weak self] searchResponse in
                self?.presenter?.presentData(response: Search.Model.Response.ResponseType.presentTracks(searchResponse: searchResponse))
            }
            
        }
        
        
    }
    
}
