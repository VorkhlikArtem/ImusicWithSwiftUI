//
//  FooterView.swift
//  iMusicApp
//
//  Created by Артём on 26.11.2022.
//

import UIKit

class FooterView: UIView {
    private var loadingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray5
        return label
    }()
    
    private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        return loader
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupElements()
    }
    
    private func setupElements() {
        addSubview(loadingLabel)
        addSubview(loader)
        
        NSLayoutConstraint.activate([
            loader.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            loader.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 8),
        ])
    }
    
    func showLoader() {
        loader.startAnimating()
        loadingLabel.text = "LOADING"
    }
    
    func hideLoader() {
        loader.stopAnimating()
        loadingLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
