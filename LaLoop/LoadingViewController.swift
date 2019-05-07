//
//  LoadingViewController.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-03.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit
import CoreData

class LoadingViewController: UIViewController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    var presentViewController: UITabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Util.Color.backgroundColor
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        view.addConstraints([NSLayoutConstraint(item: subtitleLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: subtitleLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)])
        subtitleLabel.text = "Upcoming Music Releases"
        subtitleLabel.textColor = .white
        subtitleLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        view.addConstraints([NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 8),
                             NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -8),
                             NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: subtitleLabel, attribute: .top, multiplier: 1.0, constant: 0)])
        titleLabel.text = "LaLoop"
        titleLabel.textColor = Util.Color.main
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Arial-BoldMT", size: 46)
        
        Util.getData() { (success) in
            DispatchQueue.main.async {
                
                ((self.presentViewController.selectedViewController as! UINavigationController).topViewController as! BrowseViewController).connected = success
                self.present(self.presentViewController, animated: false)
            }
        }
    }
}
