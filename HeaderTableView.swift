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
    @objc optional func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    @objc optional func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func numberOfSections(in tableView: UITableView) -> Int

    @objc optional func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    @objc optional func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    @objc optional func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
}

class HeaderTableView: UIView {

    private var refreshControl = UIRefreshControl()
    private var headerView = UIView()
    private var headerLabel = UILabel()
    private var previousScrollOffset: CGFloat = 0
    private var title = ""
    private var includeSearchBar = false
    private var errorLabel = UILabel()
    lazy var searchBar = UISearchBar()
    var maxHeaderHeight: CGFloat!
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
    
    init(frame: CGRect, style: UITableView.Style, title: String, includeSearchBar: Bool = false) {
        super.init(frame: frame)
        
        self.title = title
        self.includeSearchBar = includeSearchBar
        
        maxHeaderHeight = includeSearchBar ? 100 : 50
        tableView = UITableView(frame: .zero, style: style)
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorLabel)
        addConstraints([NSLayoutConstraint(item: errorLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 18),
                        NSLayoutConstraint(item: errorLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -18),
                        NSLayoutConstraint(item: errorLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)])
        errorLabel.setupLabel(fontWeight: .bold, fontSize: errorLabel.font.pointSize, textColor: Util.Color.main)
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerView)
        addConstraints([NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: headerView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0),
                             NSLayoutConstraint(item: headerView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)])
        headerViewHeightConstraint = NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: maxHeaderHeight)
        addConstraint(headerViewHeightConstraint)
        headerView.backgroundColor = Util.Color.backgroundColor
        
        if includeSearchBar {
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(searchBar)
            headerView.addConstraints([NSLayoutConstraint(item: searchBar, attribute: .left, relatedBy: .equal, toItem: headerView, attribute: .left, multiplier: 1.0, constant: 0),
                                       NSLayoutConstraint(item: searchBar, attribute: .right, relatedBy: .equal, toItem: headerView, attribute: .right, multiplier: 1.0, constant: 0),
                                       NSLayoutConstraint(item: searchBar, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1.0, constant: 0)])
            searchBar.barStyle = .blackTranslucent
            searchBar.barTintColor = Util.Color.backgroundColor
            searchBar.showsCancelButton = true
            searchBar.tintColor = Util.Color.secondary
            (searchBar.value(forKey: "searchField") as? UITextField)?.textColor = .white
            searchBar.delegate = self
            searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        }
        
        let bottomConstant = includeSearchBar ? maxHeaderHeight / -2 : 0
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerLabel)
        headerView.addConstraints([NSLayoutConstraint(item: headerLabel, attribute: .left, relatedBy: .equal, toItem: headerView, attribute: .left, multiplier: 1.0, constant: 20),
                                   NSLayoutConstraint(item: headerLabel, attribute: .right, relatedBy: .equal, toItem: headerView, attribute: .right, multiplier: 1.0, constant: 0),
                                   NSLayoutConstraint(item: headerLabel, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1.0, constant: bottomConstant)])
        headerLabel.text = title
        headerLabel.setupLabel(fontWeight: .bold, fontSize: 50, textColor: .white)
        
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
    
    func setupErrorMessage(isHidden: Bool, searchString: String = "") {
        errorLabel.isHidden = isHidden
        tableView.isHidden = !isHidden
        errorLabel.text = "Couldn't find \"\(searchString)\""
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate?.numberOfSections(in: tableView) ?? 0
    }
                            
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return delegate?.tableView?(tableView, editActionsForRowAt: indexPath) ?? []
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return delegate?.tableView?(tableView, heightForHeaderInSection: section) ?? 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegate?.tableView?(tableView, viewForHeaderInSection: section)
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
    
    func collapse(to position: CGFloat, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.headerViewHeightConstraint.constant = position
            self.updateHeader()
            self.layoutIfNeeded()
        }
    }
    
    func expand(to position: CGFloat, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.headerViewHeightConstraint.constant = position
            self.updateHeader()
            self.layoutIfNeeded()
        }
    }
    
    func scrollViewDidStopScrolling() {
        layoutIfNeeded()
        let mid = (maxHeaderHeight - minHeaderHeight) / 2 + minHeaderHeight

        switch includeSearchBar {
        case true:
            if headerViewHeightConstraint.constant > mid + maxHeaderHeight / 4 {
                expand(to: maxHeaderHeight)
            } else if headerViewHeightConstraint.constant > mid {
                collapse(to: mid)
            } else if headerViewHeightConstraint.constant < mid - maxHeaderHeight / 4 {
                collapse(to: minHeaderHeight)
            } else {
                expand(to: mid)
            }
        default:
            headerViewHeightConstraint.constant > mid ? expand(to: maxHeaderHeight) : collapse(to: minHeaderHeight)
        }
    }
    
    func updateHeader() {
        let range = includeSearchBar ? (maxHeaderHeight - minHeaderHeight) / 2 : maxHeaderHeight - minHeaderHeight
        let openAmount = includeSearchBar ? headerViewHeightConstraint.constant - maxHeaderHeight / 2 - minHeaderHeight : headerViewHeightConstraint.constant - minHeaderHeight
        let percentage = openAmount / range
        
        headerLabel.alpha = percentage
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(1 - percentage)]
    }
}

extension HeaderTableView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchBarSearchButtonClicked?(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.searchBarCancelButtonClicked?(searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBar?(searchBar, textDidChange: searchText)
    }
}
