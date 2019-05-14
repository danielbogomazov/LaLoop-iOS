//
//  RecordingCell.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-03-25.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

class RecordingCell: UITableViewCell {
    
    private lazy var followingButton = UIButton()
    private lazy var dateLabel = UILabel()
    private lazy var recordingLabel = UILabel()
    private lazy var artistLabel = UILabel()

    var recordingViewModel: RecordingViewModel! {
        didSet {
            artistLabel.text = recordingViewModel.artistName
            recordingLabel.text = recordingViewModel.recordingName
            dateLabel.text = recordingViewModel.releaseDate
            followingButton.setImage(recordingViewModel.followingImage, for: .normal)
            backgroundColor = recordingViewModel.backgroundColor
        }
    }
    
    var dateLabelFontSize: CGFloat {
        get { return dateLabel.font.pointSize }
        set { dateLabel.setupLabel(fontWeight: .regular, fontSize: newValue) }
    }
    var recordingLabelFontSize: CGFloat {
        get { return recordingLabel.font.pointSize }
        set { recordingLabel.setupLabel(fontWeight: .heavy, fontSize: newValue) }
    }
    var artistLabelFontSize: CGFloat {
        get { return artistLabel.font.pointSize }
        set { artistLabel.setupLabel(fontWeight: .black, fontSize: newValue, textColor: Util.Color.main) }
    }
    
    var includeFollowingButton: Bool = false {
        didSet {
            createAndUpdateConstraints()
        }
    }
    var includeArtistLabel: Bool = false {
        didSet {
            createAndUpdateConstraints()
        }
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: "recordingCell")
        selectionStyle = .none
        createAndUpdateConstraints()
    }
    
    func createAndUpdateConstraints() {
        if includeFollowingButton {
            contentView.addSubview(followingButton)
            followingButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraints([NSLayoutConstraint(item: followingButton, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: followingButton, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: followingButton, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: followingButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 72)])
            followingButton.addTarget(self, action: #selector(followingButtonPressed(_:)), for: .touchUpInside)
        }
        
        let wrapperView = UIView()
        contentView.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        let rightItem = includeFollowingButton ? followingButton : contentView
        let rightAttribute: NSLayoutConstraint.Attribute = includeFollowingButton ? .left : .right
        contentView.addConstraints([NSLayoutConstraint(item: wrapperView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 20),
                                    NSLayoutConstraint(item: wrapperView, attribute: .right, relatedBy: .equal, toItem: rightItem, attribute: rightAttribute, multiplier: 1.0, constant: -16)])
        
        if includeArtistLabel {
            wrapperView.addSubview(artistLabel)
            artistLabel.translatesAutoresizingMaskIntoConstraints = false
            let heightMultiplier: CGFloat = includeArtistLabel ? 0.4 : 0.5
            wrapperView.addConstraints([NSLayoutConstraint(item: artistLabel, attribute: .top, relatedBy: .equal, toItem: wrapperView, attribute: .top, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: artistLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: artistLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: artistLabel, attribute: .height, relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: heightMultiplier, constant: 0)])
            artistLabel.setupLabel(fontWeight: .black, fontSize: artistLabel.font.pointSize, textColor: Util.Color.main)
        }
        
        let heightMultiplier: CGFloat = includeArtistLabel ? 0.3 : 0.5
        
        wrapperView.addSubview(recordingLabel)
        recordingLabel.translatesAutoresizingMaskIntoConstraints = false
        let topItem = includeArtistLabel ? artistLabel : wrapperView
        let topAttribute: NSLayoutConstraint.Attribute = includeArtistLabel ? .bottom : .top
        wrapperView.addConstraints([NSLayoutConstraint(item: recordingLabel, attribute: .top, relatedBy: .equal, toItem: topItem, attribute: topAttribute, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: recordingLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: recordingLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: recordingLabel, attribute: .height, relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: heightMultiplier, constant: 0)])
        recordingLabel.setupLabel(fontWeight: .heavy, fontSize: recordingLabel.font.pointSize)
        
        wrapperView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addConstraints([NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: recordingLabel, attribute: .bottom, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: dateLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: dateLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: dateLabel, attribute: .height, relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: heightMultiplier, constant: 0)])
        dateLabel.setupLabel(fontWeight: .regular, fontSize: dateLabel.font.pointSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func followingButtonPressed(_ sender: UIButton) {
        recordingViewModel.changeFollowingStatus()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
