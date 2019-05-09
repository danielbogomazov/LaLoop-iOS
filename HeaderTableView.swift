//
//  HeaderTableView.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-08.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit

@objc protocol HeaderViewDelegate {
    @objc optional func refresh(completionHandler: @escaping () -> Void)
    @objc optional func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    @objc optional func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    func numberOfSections(in tableView: UITableView) -> Int
}

class HeaderTableView: UIView {

    private var refreshControl = UIRefreshControl()
    private var headerView = UIView()
    private var headerLabel = UILabel()
    private var previousScrollOffset: CGFloat = 0
    private var title = ""
    let maxHeaderHeight: CGFloat = 50
    let minHeaderHeight: CGFloat = 0
    var tableView: UITableView!
    var headerViewHeightConstraint: NSLayoutConstraint!
    var navigationController: UINavigationController?
    var delegate: HeaderViewDelegate?
    
    var canRefresh: Bool = false {
        didSet {
            if canRefresh {
                refreshControl.addTarget(self, action: #selector(ref(_:)), for: .valueChanged)
                tableView.refreshControl = refreshControl
            } else {
                refreshControl.removeTarget(self, action: #selector(ref(_:)), for: .valueChanged)
                tableView.refreshControl = nil
            }
        }
    }
    
    init(frame: CGRect, style: UITableView.Style, title: String) {
        super.init(frame: frame)
        
        self.title = title
        tableView = UITableView(frame: frame, style: style)
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerView)
        addConstraints([NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: headerView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: headerView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)])
        headerViewHeightConstraint = NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: maxHeaderHeight)
        addConstraint(headerViewHeightConstraint)
        headerView.backgroundColor = Util.Color.backgroundColor
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerLabel)
        headerView.addConstraints([NSLayoutConstraint(item: headerLabel, attribute: .left, relatedBy: .equal, toItem: headerView, attribute: .left, multiplier: 1.0, constant: 20),
                                   NSLayoutConstraint(item: headerLabel, attribute: .right, relatedBy: .equal, toItem: headerView, attribute: .right, multiplier: 1.0, constant: 0),
                                   NSLayoutConstraint(item: headerLabel, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1.0, constant: 0)])
        headerLabel.text = title
        headerLabel.setupLabel(fontWeight: .bold, fontSize: 50, textColor: .white)
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        addConstraints([NSLayoutConstraint(item: tableView!, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: tableView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: tableView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: tableView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)])
        tableView.backgroundColor = Util.Color.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc func ref(_ sender: UIRefreshControl) {
        delegate?.refresh? {
            self.refreshControl.endRefreshing()
        }
    }
}

extension HeaderTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return delegate?.tableView(tableView, cellForRowAt: indexPath) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return delegate?.tableView(tableView, heightForRowAt: indexPath) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return delegate?.tableView(tableView, heightForHeaderInSection: section) ?? 0
    }
                    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegate?.tableView(tableView, viewForHeaderInSection: section)
    }
                        
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate?.numberOfSections(in: tableView) ?? 0
    }
                            
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return delegate?.tableView?(tableView, editActionsForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // Don't collapse if there aren't enough cells to scroll through
        if scrollView.contentSize.height <= scrollView.frame.height + headerViewHeightConstraint.constant - minHeaderHeight {
            return
        }
        
        let absoluteTop: CGFloat = 0
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        
        let scrollDiff = scrollView.contentOffset.y - previousScrollOffset
        var newHeight = headerViewHeightConstraint.constant
        
        if scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop {
            // Scrolling up
            newHeight = max(minHeaderHeight, headerViewHeightConstraint.constant - abs(scrollDiff))
            updateHeader()
        } else if scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom && tableView.contentOffset.y < minHeaderHeight {
            // Scrolling down
            newHeight = min(maxHeaderHeight, headerViewHeightConstraint.constant + abs(scrollDiff))
            updateHeader()
        }
        
        if newHeight != headerViewHeightConstraint.constant {
            headerViewHeightConstraint.constant = newHeight
            setScrollPosition(for: tableView, position: previousScrollOffset)
        }
        
        previousScrollOffset = scrollView.contentOffset.y
    }
    
    func setScrollPosition(for tableView: UITableView, position: CGFloat) {
        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: position)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Scrolling has stopped
        scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // Scrolling has stopped
            scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        layoutIfNeeded()
        let mid = (maxHeaderHeight - minHeaderHeight) / 2 + minHeaderHeight
        
        if headerViewHeightConstraint.constant > mid {
            // Expand
            UIView.animate(withDuration: 0.3) {
                self.headerViewHeightConstraint.constant = self.maxHeaderHeight
                self.layoutIfNeeded()
            }
        } else {
            // Collapse
            UIView.animate(withDuration: 0.3) {
                self.headerViewHeightConstraint.constant = self.minHeaderHeight
                self.layoutIfNeeded()
            }
        }
    }
    
    func updateHeader() {
        let range = maxHeaderHeight - minHeaderHeight
        let openAmount = headerViewHeightConstraint.constant - minHeaderHeight
        let percentage = openAmount / range
        
        headerLabel.alpha = percentage
        
        if percentage == 0 {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(1)]
        } else {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0)]
        }
    }
    
}
