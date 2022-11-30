//
//  TrackCell.swift
//  iMusicApp
//
//  Created by Артём on 26.11.2022.
//

import UIKit
import SDWebImage

protocol TrackCellViewModel {
    var iconUrlString: String? {get}
    var trackName: String {get}
    var artistName: String {get}
    var collectionName: String {get}
}

class TrackCell: UITableViewCell {
    static let reuseId = "TrackCell"
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var addTrackButton: UIButton!
    
    var cell: SearchViewModel.Cell?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumImageView.image = nil
    }
    
    func setupCell(with trackViewModel: SearchViewModel.Cell) {
        self.cell = trackViewModel
        let savedTracks = UserDefaults.standard.getSavedTracks()
        if savedTracks.firstIndex(where: { $0.trackName == cell?.trackName && $0.artistName == cell?.artistName }) != nil {
            addTrackButton.isHidden = true
        } else {
            addTrackButton.isHidden = false
        }
        
        trackNameLabel.text = trackViewModel.trackName
        artistNameLabel.text = trackViewModel.artistName
        collectionNameLabel.text = trackViewModel.collectionName
        
        guard let imageUrl = URL(string: trackViewModel.iconUrlString ?? "") else {
            albumImageView.image = #imageLiteral(resourceName: "artem")
            return
        }
        albumImageView.sd_setImage(with: imageUrl, completed: nil)
    }
    
    @IBAction func addTrackTapped(_ sender: Any) {
        addTrackButton.isHidden = true
        let defaults = UserDefaults.standard
        guard let cell = cell else {return}
        var listOfTracks = UserDefaults.standard.getSavedTracks()
        listOfTracks.insert(cell, at: 0)
        
        
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: listOfTracks, requiringSecureCoding: false) {
            defaults.set(savedData, forKey: UserDefaults.favoriteTracksKey)
        }

    }
    
}
