//
//  CMTime + Extention.swift
//  iMusicApp
//
//  Created by Артём on 27.11.2022.
//

import Foundation
import AVKit

extension CMTime {
    func convertToString() -> String {
        guard !CMTimeGetSeconds(self).isNaN else {return ""}
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let timeStringFormat = String(format: "%02d:%02d", minutes, seconds)
        return timeStringFormat
    }
}
