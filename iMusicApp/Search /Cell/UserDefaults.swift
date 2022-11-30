//
//  UserDefaults.swift
//  iMusicApp
//
//  Created by Артём on 28.11.2022.
//

import Foundation

extension UserDefaults{
    static let favoriteTracksKey = "FavoriteTracksKey"
    
    func getSavedTracks() -> [SearchViewModel.Cell] {
        let defaults = UserDefaults.standard
        
        guard let savedTracks = defaults.object(forKey: Self.favoriteTracksKey) as? Data else { return [] }
        guard let decodedTracks = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedTracks) as? [SearchViewModel.Cell] else { return [] }
        return decodedTracks
    }
}
