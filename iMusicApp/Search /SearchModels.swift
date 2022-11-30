//
//  SearchModels.swift
//  iMusicApp
//
//  Created by Артём on 26.11.2022.


import UIKit
import SwiftUI

enum Search {
    
    enum Model {
        struct Request {
            enum RequestType {
                
                case getTracks(searchString: String)
            }
        }
        struct Response {
            enum ResponseType {
                
                case presentTracks(searchResponse: SearchResponse?)
                case presentFooterView
            }
        }
        struct ViewModel {
            enum ViewModelData {
                
                case displayTracks(searchViewModel: SearchViewModel)
                case displayFooterView
            }
        }
    }
    
}

class SearchViewModel: NSObject, NSCoding {
    let cells: [Cell]
    
    @objc(_TtCC9iMusicApp15SearchViewModel4Cell)class Cell: NSObject, NSCoding, Identifiable {
       
        var id = UUID()
        var trackName: String
        var collectionName: String
        var artistName: String
        var iconUrlString: String?
        var previewUrl: String?
        
        func encode(with coder: NSCoder) {
            coder.encode(trackName, forKey: "trackName")
            coder.encode(collectionName, forKey: "collectionName")
            coder.encode(artistName, forKey: "artistName")
            coder.encode(iconUrlString, forKey: "iconUrlString")
            coder.encode(previewUrl, forKey: "previewUrl")
        }
        
        required init?(coder: NSCoder) {
            trackName = coder.decodeObject(forKey: "trackName") as? String ?? ""
            collectionName = coder.decodeObject(forKey: "collectionName") as? String ?? ""
            artistName = coder.decodeObject(forKey: "artistName") as? String ?? ""
            iconUrlString = coder.decodeObject(forKey: "iconUrlString") as? String? ?? ""
            previewUrl = coder.decodeObject(forKey: "previewUrl") as? String? ?? ""
        }
        
        init(trackName: String, collectionName: String, artistName: String, iconUrlString: String?, previewUrl: String?) {
            self.trackName = trackName
            self.collectionName = collectionName
            self.artistName = artistName
            self.iconUrlString = iconUrlString
            self.previewUrl = previewUrl
        }
        
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(cells, forKey: "cells")
    }
    
    required init?(coder: NSCoder) {
        cells = coder.decodeObject(forKey: "cells") as? [SearchViewModel.Cell] ?? []
    }
    
    init(cells: [Cell]) {
        self.cells = cells
    }
}
