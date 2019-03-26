//
//  ArtistCell.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2019-03-26.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

class ArtistCell: UITableViewCell {
    
    lazy var artistLabel = UILabel()
    lazy var upcomingLabel = UILabel()
    
    var artistName: String {
        get { return artistLabel.text! }
    }
    var recordingName: String {
        get { return upcomingLabel.text! }
    }
    var bgColor: UIColor? {
        get { return backgroundColor }
        set { backgroundColor = newValue }
    }
    var artistLabelFontSize: CGFloat {
        get { return artistLabel.font.pointSize }
        set { artistLabel.setupLabel(fontWeight: .black, fontSize: newValue, textColor: Util.Color.main) }
    }
    var upcomingLabelFontSize: CGFloat {
        get { return upcomingLabel.font.pointSize }
        set { upcomingLabel.setupLabel(fontWeight: .regular, fontSize: newValue) }
    }

    
    init(artist: Artist) {
        super.init(style: .default, reuseIdentifier: "artistCell")
        
        backgroundColor = Util.Color.backgroundColor
        selectionStyle = .none

        let wrapperView = UIView()
        contentView.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([NSLayoutConstraint(item: wrapperView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -8)])

        wrapperView.addSubview(artistLabel)
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addConstraints([NSLayoutConstraint(item: artistLabel, attribute: .top, relatedBy: .equal, toItem: wrapperView, attribute: .top, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: artistLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: artistLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: artistLabel, attribute: .height
                                        , relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: 0.65, constant: 0)])
        artistLabel.setupLabel(fontWeight: .black, fontSize: artistLabel.font.pointSize, textColor: Util.Color.main)
        artistLabel.text = artist.name
        
        wrapperView.addSubview(upcomingLabel)
        upcomingLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addConstraints([NSLayoutConstraint(item: upcomingLabel, attribute: .top, relatedBy: .equal, toItem: artistLabel, attribute: .bottom, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: upcomingLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: upcomingLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: upcomingLabel, attribute: .height, relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: 0.35, constant: 0)])
        upcomingLabel.setupLabel(fontWeight: .regular, fontSize: upcomingLabel.font.pointSize)
        let numRecordings = artist.recordings.count
        upcomingLabel.text = "\(numRecordings) upcoming recording" + (numRecordings > 1 ? "s" : "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
