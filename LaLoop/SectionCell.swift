//
//  SectionCell.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-02.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

class SectionCell: UITableViewCell {
    
    private lazy var titleLabel = UILabel()
    private lazy var detailLabel = UILabel()
    private lazy var selectionSwitch = UISwitch()
    
    var switchAction: ((Any) -> Void)?
    
    var sectionViewModel: SectionViewModel! {
        didSet {
            titleLabel.text = sectionViewModel.title
            detailLabel.text = sectionViewModel.detail
            selectionSwitch.isOn = sectionViewModel.isOn
            createAndUpdateConstraints()
        }
    }
    
    init() {
        super.init(style: .subtitle, reuseIdentifier: "sectionCell")
        backgroundColor = UIColor.white.withAlphaComponent(0.03)
        selectionStyle = .none
        createAndUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createAndUpdateConstraints() {

        let wrapperView = UIView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrapperView)
        contentView.addConstraints([NSLayoutConstraint(item: wrapperView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 12),
                                    NSLayoutConstraint(item: wrapperView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -20),
                                    NSLayoutConstraint(item: wrapperView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0)])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(titleLabel)
        wrapperView.addConstraints([NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: wrapperView, attribute: .top, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                    NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0)])
        
        titleLabel.setupLabel(fontWeight: .medium, fontSize: 18, textColor: .white)
        titleLabel.numberOfLines = 1
        
        if detailLabel.text != "" && detailLabel.text != nil {
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            wrapperView.addSubview(detailLabel)
            wrapperView.addConstraints([NSLayoutConstraint(item: detailLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: detailLabel, attribute: .left, relatedBy: .equal, toItem: wrapperView, attribute: .left, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: detailLabel, attribute: .right, relatedBy: .equal, toItem: wrapperView, attribute: .right, multiplier: 1.0, constant: 0),
                                        NSLayoutConstraint(item: detailLabel, attribute: .bottom, relatedBy: .equal, toItem: wrapperView, attribute: .bottom, multiplier: 1.0, constant: 0)])
            detailLabel.setupLabel(fontWeight: .thin, fontSize: 12, textColor: UIColor.white.withAlphaComponent(0.5))
        } else {
            contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: wrapperView, attribute: .bottom, multiplier: 1.0, constant: 0))
        }
        
        selectionSwitch.translatesAutoresizingMaskIntoConstraints = false
        accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: selectionSwitch.frame.width, height: selectionSwitch.frame.height))
        accessoryView?.addSubview(selectionSwitch)
        accessoryView?.addConstraints([NSLayoutConstraint(item: selectionSwitch, attribute: .right, relatedBy: .equal, toItem: accessoryView, attribute: .right, multiplier: 1.0, constant: -12),
                                       NSLayoutConstraint(item: selectionSwitch, attribute: .centerY, relatedBy: .equal, toItem: accessoryView, attribute: .centerY, multiplier: 1.0, constant: 0)])
        selectionSwitch.onTintColor = Util.Color.main
        selectionSwitch.tintColor = Util.Color.main
        selectionSwitch.addTarget(self, action: #selector(selectionSwitchDidChangeValue(_:)), for: .valueChanged)

    }
    
    @objc func selectionSwitchDidChangeValue(_ sender: UISwitch) {
        switchAction?(sender)
    }
}
