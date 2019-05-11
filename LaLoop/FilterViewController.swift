//
//  FilterViewController.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-09.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import UIKit
import CoreData

class FilterViewController: UIViewController {

    private let genreCellID = "genreCollectionCell"
    private let errorLabel = UILabel()
    private let genreLabel = UILabel()
    private let dateLabel = UILabel()
    private let dateFilterSegmentedControl = UISegmentedControl(items: ["TODAY", "PAST WEEK", "PAST MONTH", "ALL TIME"])
    private var genresCollectionView: UICollectionView!
    var browseViewController: BrowseViewController?
    
    let genres = [Util.Genres.avant_garde, Util.Genres.blues, Util.Genres.caribbean, Util.Genres.childrens, Util.Genres.classical, Util.Genres.comedy, Util.Genres.country, Util.Genres.electronic, Util.Genres.experimental, Util.Genres.folk, Util.Genres.hip_hop, Util.Genres.jazz, Util.Genres.latin, Util.Genres.pop, Util.Genres.rnb_and_soul, Util.Genres.rock, Util.Genres.worship]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Util.Color.backgroundColor
        
        navigationController?.navigationBar.barStyle = .blackOpaque
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Util.Color.secondaryDark
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "RESET", style: .plain, target: self, action: #selector(resetButtonPressed(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "FILTER", style: .done, target: self, action: #selector(filterButtonPressed(_:)))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        genresCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        genresCollectionView.dataSource = self
        genresCollectionView.delegate = self
        genresCollectionView.register(FilterCollectionCell.self, forCellWithReuseIdentifier: genreCellID)

        if let dateFilter = self.browseViewController?.dateFilter {
            switch dateFilter {
            case .today:
                dateFilterSegmentedControl.selectedSegmentIndex = 0
            case .pastWeek:
                dateFilterSegmentedControl.selectedSegmentIndex = 1
            case .pastMonth:
                dateFilterSegmentedControl.selectedSegmentIndex = 2
            default:
                dateFilterSegmentedControl.selectedSegmentIndex = 3
            }
        } else {
            dateFilterSegmentedControl.selectedSegmentIndex = 3
        }
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateFilterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        genresCollectionView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)
        view.addSubview(dateFilterSegmentedControl)
        view.addSubview(genreLabel)
        view.addSubview(genresCollectionView)
        view.addSubview(errorLabel)

        
        view.addConstraints([NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 32),
            NSLayoutConstraint(item: dateLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 16),
            NSLayoutConstraint(item: dateLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -16)])
        dateLabel.text = "DATE ADDED"
        dateLabel.setupLabel(fontWeight: .heavy, fontSize: 30, textColor: Util.Color.main)
        
        view.addConstraints([NSLayoutConstraint(item: dateFilterSegmentedControl, attribute: .top, relatedBy: .equal, toItem: dateLabel, attribute: .bottom, multiplier: 1.0, constant: 16),
                             NSLayoutConstraint(item: dateFilterSegmentedControl, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 16),
                             NSLayoutConstraint(item: dateFilterSegmentedControl, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -16)])
        dateFilterSegmentedControl.tintColor = .white
        dateFilterSegmentedControl.addTarget(self, action: #selector(dateFilterValueChanged(_:)), for: .valueChanged)

        view.addConstraints([NSLayoutConstraint(item: genreLabel, attribute: .top, relatedBy: .equal, toItem: dateFilterSegmentedControl, attribute: .bottom, multiplier: 1.0, constant: 32),
                             NSLayoutConstraint(item: genreLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 16),
                             NSLayoutConstraint(item: genreLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 16)])
        genreLabel.text = "GENRES"
        genreLabel.setupLabel(fontWeight: .heavy, fontSize: 30, textColor: Util.Color.main)

        view.addConstraints([NSLayoutConstraint(item: genresCollectionView!, attribute: .top, relatedBy: .equal, toItem: genreLabel, attribute: .bottom, multiplier: 1.0, constant: 16),
                             NSLayoutConstraint(item: genresCollectionView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 16),
                             NSLayoutConstraint(item: genresCollectionView!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -16),
                             NSLayoutConstraint(item: genresCollectionView!, attribute: .bottom, relatedBy: .equal, toItem: errorLabel, attribute: .top, multiplier: 1.0, constant: -8)])
        genresCollectionView.backgroundColor = Util.Color.backgroundColor
        
        view.addConstraints([NSLayoutConstraint(item: errorLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 16),
                             NSLayoutConstraint(item: errorLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -16),
                             NSLayoutConstraint(item: errorLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -32)])
        errorLabel.text = "No recordings found for these filters"
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
    }
    
    @objc func filterButtonPressed(_ sender: UIBarButtonItem) {
        
        var filteredRecordings = AppDelegate.recordings
        
        // Date filter
        switch dateFilterSegmentedControl.selectedSegmentIndex {
        case 0:
            browseViewController?.dateFilter = .today
            filteredRecordings = AppDelegate.recordings.filter {
                guard let dateAdded = $0.date_added else { return false }
                return dateAdded.timeIntervalSinceNow >= (60 * 60 * 24 * -1)
            }
        case 1:
            browseViewController?.dateFilter = .pastWeek
            filteredRecordings = AppDelegate.recordings.filter {
                guard let dateAdded = $0.date_added else { return false }
                return dateAdded.timeIntervalSinceNow >= (60 * 60 * 24 * 7 * -1)
            }
        case 2:
            browseViewController?.dateFilter = .pastMonth
            filteredRecordings = AppDelegate.recordings.filter {
                guard let dateAdded = $0.date_added else { return false }
                // 31 as the arbitrary date count, being specific doesn't really matter
                return dateAdded.timeIntervalSinceNow >= (60 * 60 * 24 * 31 * -1)
            }
        case 3:
            browseViewController?.dateFilter = .allTime
        default:
            fatalError()
        }
        
        // Genres filter
        for genre in browseViewController?.genresFilter ?? [] {
            filteredRecordings = filteredRecordings.filter {
                let genres = Array($0.genres) + ($0.artists.first?.genres ?? [])
                
                for g in genres {
                    if g.name == genre {
                        return true
                    }
                }
                return false
            }
        }
        
        if filteredRecordings.count == 0 {
            errorLabel.isHidden = false
        } else {
            browseViewController?.filteredRecordings = filteredRecordings
            browseViewController?.searchRecordings()
            browseViewController?.reloadTableView()
            browseViewController?.navigationItem.leftBarButtonItem?.image = (browseViewController?.dateFilter == .allTime && browseViewController?.genresFilter.count == 0) ? #imageLiteral(resourceName: "Filter").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "Filtered").withRenderingMode(.alwaysOriginal)
            dismiss(animated: true)
        }
    }
    
    @objc func resetButtonPressed(_ sender: UIBarButtonItem) {
        errorLabel.isHidden = true
        browseViewController?.dateFilter = .allTime
        browseViewController?.filteredRecordings = []
        dateFilterSegmentedControl.selectedSegmentIndex = 3
        browseViewController?.genresFilter = []
        genresCollectionView.reloadData()
    }

    @objc func dateFilterValueChanged(_ sender: UISegmentedControl) {
        errorLabel.isHidden = true
    }
    
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: genreCellID, for: indexPath) as! FilterCollectionCell
        let genre = genres[indexPath.row]
        
        cell.backgroundColor = browseViewController?.genresFilter.contains(genre) ?? false ? UIColor.white.withAlphaComponent(0.5) : .clear

        cell.titleLabel.text = genre
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        return cell
    }
    
    func collectionView(_ collection: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collection.frame.width / 3 - 10, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FilterCollectionCell
        guard let genre = cell.titleLabel.text else { return }
        
        if browseViewController?.genresFilter.contains(genre) ?? false {
            browseViewController?.genresFilter.removeAll { $0 == genre }
            cell.backgroundColor = .clear
        } else {
            browseViewController?.genresFilter.append(genre)
            cell.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
}

class FilterCollectionCell: UICollectionViewCell {
    
    var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addConstraints([NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0),
                        NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0)])
        titleLabel.setupLabel(fontWeight: .bold, fontSize: titleLabel.font.pointSize, textColor: .white)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
