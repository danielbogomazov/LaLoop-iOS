//
//  RecordingCell.swift
//  apollo-iOS
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
    
    var bgColor: UIColor? {
        get { return backgroundColor }
        set { backgroundColor = newValue }
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
    
    init(excludeFollowingButton: Bool = false, excludeArtist: Bool = false, excludeRecording: Bool = false) {
        super.init(style: .default, reuseIdentifier: "recordingCell")
        
        selectionStyle = .none
        
        if !excludeFollowingButton {
            contentView.addSubview(followingButton)
            followingButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraints([NSLayoutConstraint(item: followingButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 24),
                                        NSLayoutConstraint(item: followingButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 24),
                                        NSLayoutConstraint(item: followingButton, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: followingButton, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -32)])
            followingButton.addTarget(self, action: #selector(followingButtonPressed(_:)), for: .touchUpInside)
        }
        
        let wrapperView = UIView()
        contentView.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        let rightItem = excludeFollowingButton ? contentView : followingButton
        let rightAttribute: NSLayoutConstraint.Attribute = excludeFollowingButton ? .right : .left
        contentView.addConstraints([NSLayoutConstraint(item: wrapperView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .right, relatedBy: .equal, toItem: rightItem, attribute: rightAttribute, multiplier: 1.0, constant: -16)])
        
        if !excludeArtist {
            wrapperView.addSubview(artistLabel)
            artistLabel.translatesAutoresizingMaskIntoConstraints = false
            let heightMultiplier: CGFloat = excludeRecording ? 0.5 : 0.4
            wrapperView.addConstraints([NSLayoutConstraint(item: artistLabel, attribute: .top, relatedBy: .equal, toItem: wrapperView, attribute: .top, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: artistLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: artistLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: artistLabel, attribute: .height, relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: heightMultiplier, constant: 0)])
            artistLabel.setupLabel(fontWeight: .black, fontSize: artistLabel.font.pointSize, textColor: Util.Color.main)
        }
        
        let heightMultiplier: CGFloat = (excludeArtist && excludeRecording) ? 1.0 : (excludeArtist || excludeRecording) ? 0.5 : 0.3

        if !excludeRecording {
            wrapperView.addSubview(recordingLabel)
            recordingLabel.translatesAutoresizingMaskIntoConstraints = false
            let topItem = excludeArtist ? wrapperView : artistLabel
            let topAttribute: NSLayoutConstraint.Attribute = excludeArtist ? .top : .bottom
            wrapperView.addConstraints([NSLayoutConstraint(item: recordingLabel, attribute: .top, relatedBy: .equal, toItem: topItem, attribute: topAttribute, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: recordingLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: recordingLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: recordingLabel, attribute: .height, relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: heightMultiplier, constant: 0)])
            recordingLabel.setupLabel(fontWeight: .heavy, fontSize: recordingLabel.font.pointSize)
        }
        
        wrapperView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        let topItem = !excludeRecording ? recordingLabel : !excludeArtist ? artistLabel : wrapperView
        let topAttribute: NSLayoutConstraint.Attribute = (!excludeRecording || !excludeArtist) ? .bottom : .top
        wrapperView.addConstraints([NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: topItem, attribute: topAttribute, multiplier: 1.0, constant: 0),
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
    }
}
