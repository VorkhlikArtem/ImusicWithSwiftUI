//
//  MainTabBarController.swift
//  iMusicApp
//
//  Created by Артём on 25.11.2022.
//

import UIKit
import SwiftUI

protocol MainTabBarControllerDelegate: AnyObject {
    func minimizeTrackDetailController()
    func maximizeTrackDetailController(cellViewModel: SearchViewModel.Cell?)
}

class MainTabBarController: UITabBarController {
    
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .red
        tabBar.backgroundColor = .white
        setupTrackDetailView()
        searchVC.tabBarDelegate = self
        
        var library = Library()
        library.tabBarDelegate = self
        let hostVC = UIHostingController(rootView: library)
        hostVC.tabBarItem.image = #imageLiteral(resourceName: "library")
        hostVC.tabBarItem.title = "Library"
        
        viewControllers = [
            generateVC(rootVC: searchVC, image: UIImage(systemName: "magnifyingglass")!, title: "Search"),
            hostVC
        ]
        
    }
    
    func generateVC(rootVC: UIViewController, image: UIImage, title: String) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootVC)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        rootVC.navigationItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
    
    
    private func setupTrackDetailView() {
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
      
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchVC
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        bottomAnchorConstraint.isActive = true
        
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    }
}

extension MainTabBarController: MainTabBarControllerDelegate {
    func maximizeTrackDetailController(cellViewModel: SearchViewModel.Cell?) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(withDuration: 1,
                       delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut, animations: {
            self.view?.layoutIfNeeded()
            self.tabBar.alpha = 0
            self.trackDetailView.miniTrackDetailView.alpha = 0
            self.trackDetailView.maximizedTrackDetailView.alpha = 1
        }, completion: nil)
        
        guard let cellViewModel = cellViewModel else {return}
        self.trackDetailView.setup(with: cellViewModel)

    }
    
    func minimizeTrackDetailController() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height //- 64 - tabBar.frame.height
        minimizedTopAnchorConstraint.isActive = true
        UIView.animate(withDuration: 1,
                       delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut, animations: {
            self.view?.layoutIfNeeded()
            self.tabBar.alpha = 1
            self.trackDetailView.miniTrackDetailView.alpha = 1
            self.trackDetailView.maximizedTrackDetailView.alpha = 0
        }, completion: nil)
    }
    
    
}
