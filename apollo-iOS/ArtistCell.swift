//
//  ArtistCell.swift
//  apollo-iOS
//
//  Created by Daniel Bogomazov on 2019-03-26.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

class ArtistCell: UITableViewCell {
    private lazy var expandImageView = UIImageView()
    private lazy var artistLabel = UILabel()
    private lazy var upcomingLabel = UILabel()
    private var artist: Artist!
    
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
    
    init(artist: Artist, isExpanded: Bool) {
        super.init(style: .default, reuseIdentifier: "artistCell")
        
        self.artist = artist
        
        backgroundColor = Util.Color.backgroundColor
        selectionStyle = .none
        
        contentView.addSubview(expandImageView)
        expandImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([NSLayoutConstraint(item: expandImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 24),
                                    NSLayoutConstraint(item: expandImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 24),
                                    NSLayoutConstraint(item: expandImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: expandImageView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -32)])
        expandImageView.image = isExpanded ? UIImage(named: "ArrowUp") : UIImage(named: "ArrowDown")

        let wrapperView = UIView()
        contentView.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([NSLayoutConstraint(item: wrapperView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .right, relatedBy: .equal, toItem: expandImageView, attribute: .left, multiplier: 1.0, constant: -8)])

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
