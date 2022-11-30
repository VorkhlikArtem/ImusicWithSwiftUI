//
//  Nib.swift
//  iMusicApp
//
//  Created by Артём on 27.11.2022.
//

import UIKit
extension UIView {
    class func loadFromNib<T:UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as! T
    }
}
