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
    private var recordingObj: Recording!
    
    var releaseDate: String {
        get { return dateLabel.text! }
    }
    var recordingName: String {
        get { return recordingLabel.text! }
    }
    var artistName: String {
        get { return artistLabel.text! }
    }
    var recording: Recording {
        get { return recordingObj }
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
    
    init(recording: Recording, excludeArtist: Bool = false, excludeFollowingButton: Bool = false) {
        super.init(style: .default, reuseIdentifier: "recordingCell")
        
        recordingObj = recording
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        if !excludeFollowingButton {
            contentView.addSubview(followingButton)
            followingButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraints([NSLayoutConstraint(item: followingButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 24),
                                        NSLayoutConstraint(item: followingButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 24),
                                        NSLayoutConstraint(item: followingButton, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: followingButton, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -32)])
            followingButton.addTarget(self, action: #selector(followingButtonPressed(_:)), for: .touchUpInside)
            updateButtonImage()
        }
        
        let wrapperView = UIView()
        contentView.addSubview(wrapperView)
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        let rightItem = excludeFollowingButton ? contentView : followingButton
        let rightAttribute: NSLayoutConstraint.Attribute = excludeFollowingButton ? .right : .left
        contentView.addConstraints([NSLayoutConstraint(item: wrapperView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 8),
                                    NSLayoutConstraint(item: wrapperView, attribute: .right, relatedBy: .equal, toItem: rightItem, attribute: rightAttribute, multiplier: 1.0, constant: -8)])
        
        if !excludeArtist {
            wrapperView.addSubview(artistLabel)
            artistLabel.translatesAutoresizingMaskIntoConstraints = false
            wrapperView.addConstraints([NSLayoutConstraint(item: artistLabel, attribute: .top, relatedBy: .equal, toItem: wrapperView, attribute: .top, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: artistLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: artistLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: artistLabel, attribute: .height, relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: 0.4, constant: 0)])
            artistLabel.setupLabel(fontWeight: .black, fontSize: artistLabel.font.pointSize, textColor: Util.Color.main)
            artistLabel.text = recordingObj.artists.first?.name ?? "Unknown Artist"
        }
        
        let heightMultiplier: CGFloat = excludeArtist ? 0.5 : 0.3

        wrapperView.addSubview(recordingLabel)
        recordingLabel.translatesAutoresizingMaskIntoConstraints = false
        let topItem = excludeArtist ? wrapperView : artistLabel
        let topAttribute: NSLayoutConstraint.Attribute = excludeArtist ? .top : .bottom
        wrapperView.addConstraints([NSLayoutConstraint(item: recordingLabel, attribute: .top, relatedBy: .equal, toItem: topItem, attribute: topAttribute, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: recordingLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: recordingLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: recordingLabel, attribute: .height, relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: heightMultiplier, constant: 0)])
        recordingLabel.setupLabel(fontWeight: .heavy, fontSize: recordingLabel.font.pointSize)
        recordingLabel.text = recording.name
        
        
        wrapperView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addConstraints([NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: recordingLabel, attribute: .bottom, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: dateLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: dateLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: dateLabel, attribute: .height, relatedBy: .equal, toItem: wrapperView, attribute: .height, multiplier: heightMultiplier, constant: 0)])
        dateLabel.setupLabel(fontWeight: .regular, fontSize: dateLabel.font.pointSize)
        if let date = recording.release_date, let years = Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).year {
            let formatter = DateFormatter()
            // TODO : years > 1000 is pretty hackish but it will do until the TBA standard is changed from the backend
            if years > 1000 {
                let newDate = Calendar.current.date(byAdding: .year, value: -1999, to: date)
                formatter.dateFormat = "MMMM YYYY"
                dateLabel.text = formatter.string(from: newDate ?? date)
            } else {
                formatter.dateFormat = "MMMM dd YYYY"
                dateLabel.text = formatter.string(from: date)
            }
        } else {
            dateLabel.text = "TBA"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateButtonImage() {
        DispatchQueue.main.async {
            if let artistID = self.recording.artists.first?.id,
                let artists = UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) as? [String],
                artists.contains(artistID) {
                self.followingButton.setImage(UIImage(named: "Followed"), for: .normal)
            } else {
                self.followingButton.setImage(UIImage(named: "NotFollowed"), for: .normal)
            }
        }
    }
    
    @objc func followingButtonPressed(_ sender: UIButton) {
        guard let followedArtists = UserDefaults.standard.array(forKey: Util.Constant.followedArtistsKey) as? [String] else { return }
        guard let id = recordingObj.artists.first?.id else { return }
        
        if followedArtists.contains(id) {
            Util.unfollowArtist(id: id)
        } else {
            Util.followArtist(id: id, recording: recording)
        }
        updateButtonImage()
    }
}
