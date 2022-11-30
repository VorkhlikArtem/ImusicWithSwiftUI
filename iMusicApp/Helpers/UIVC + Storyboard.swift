//
//  UIVC + Storyboard.swift
//  iMusicApp
//
//  Created by Артём on 26.11.2022.
//

import UIKit

extension UIViewController {
    class func loadFromStoryboard<T:UIViewController>() -> T {
        let name = String(describing: self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        if let viewController = storyboard.instantiateInitialViewController() as? T {
            return viewController
        } else {
            fatalError("Error: No such viewController")
        }
        
    }
}
