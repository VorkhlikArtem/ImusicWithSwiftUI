//
//  SearchPresenter.swift
//  iMusicApp
//
//  Created by Артём on 26.11.2022.

import UIKit

protocol SearchPresentationLogic {
    func presentData(response: Search.Model.Response.ResponseType)
}

class SearchPresenter: SearchPresentationLogic {
    weak var viewController: SearchDisplayLogic?
    
    func presentData(response: Search.Model.Response.ResponseType) {
        switch response {
       
        case .presentTracks(let searchResult):
            let cells = searchResult?.results.map { track in
                cellViewModel(from: track)
            } ?? []
            let searchViewModel = SearchViewModel(cells: cells)
            viewController?.displayData(viewModel: Search.Model.ViewModel.ViewModelData.displayTracks(searchViewModel: searchViewModel))
        case .presentFooterView:
            viewController?.displayData(viewModel: .displayFooterView)
        }
    }
    
    private func cellViewModel(from track: Track) -> SearchViewModel.Cell {
        return SearchViewModel.Cell(trackName: track.trackName,
                                    collectionName: track.collectionName ?? "",
                                    artistName: track.artistName,
                                    iconUrlString: track.artworkUrl100,
                                    previewUrl: track.previewUrl)
    }
    
}
