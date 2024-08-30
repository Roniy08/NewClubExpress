//
//  CalendarGridViewController.swift
// ClubExpress
//
//  Created by Ronit on 05/06/2024.
//  
//

import UIKit

protocol CalendarGridDelegate: class {
    func selectedDayDidChange(day: Date)
    func sizeDidChange()
}

class CalendarGridViewController: UIViewController {

    var selectedMonth: Date? {
        didSet {
            presenter?.selectedMonth = selectedMonth
        }
    }
    var selectedDay: Date? {
        didSet {
            presenter?.selectedDay = selectedDay
        }
    }
    var organisationColours: OrganisationColours!
    var presenter: CalendarGridPresenter? {
        didSet {
            presenter?.view = self
        }
    }
    fileprivate var days = Array<CalendarDay>()
    fileprivate var isAnimating = false
    weak var delegate: CalendarGridDelegate?
    
    @IBOutlet var weekdayLabels: [UILabel]!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func eventsUpdated() {
        presenter?.eventsUpdated()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        //update tableview header view height
        delegate?.sizeDidChange()
    }
    
    fileprivate func setupView() {
        styleWeekdayLabels()
        setCollectionViewCellSize()
    }
    
    fileprivate func styleWeekdayLabels() {
        for weekdayLabel in weekdayLabels {
            weekdayLabel.font = UIFont.openSansFontOfSize(size: 12)
            weekdayLabel.textColor = UIColor.mtSlateGrey
        }
    }
    
    fileprivate func setCollectionViewCellSize() {
        view.layoutIfNeeded()
        var fullWidth = view.frame.width
        if #available(iOS 11.0, *) {
            let safeAreaInsets = view.safeAreaInsets
            fullWidth -= (safeAreaInsets.left + safeAreaInsets.right)
        }
        let cellWidth = CGFloat(Double(fullWidth / 7).rounded(.towardZero))
        let cellHeight:CGFloat = 50
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        }
        
        collectionView.collectionViewLayout.invalidateLayout()
        view.layoutIfNeeded()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.setCollectionViewCellSize()
            self.setCollectionViewHeightToContent()
        }, completion: nil)
    }
    
    fileprivate func setCollectionViewHeightToContent() {
        view.layoutIfNeeded()
        let contentHeight = collectionView.contentSize.height
        collectionViewHeightConstraint.constant = contentHeight
        view.layoutIfNeeded()
    }
}

extension CalendarGridViewController: CalendarGridView {
    func setCalendarDays(days: Array<CalendarDay>, animated: Bool) {
        if animated {
            isAnimating = true
            UIView.animate(withDuration: 0.1, animations: {
                self.collectionView.alpha = 0
            }) { (completed) in
                self.isAnimating = false
                self.days = days
                self.collectionView.reloadData()
                self.setCollectionViewHeightToContent()
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.collectionView.alpha = 1
                })
            }
        } else {
            self.days = days
            if isAnimating == false {
                //only reload if not currently animating
                collectionView.reloadData()
            }
            setCollectionViewHeightToContent()
        }
    }
    
    func selectedDayDidChange(date: Date) {
        delegate?.selectedDayDidChange(day: date)
    }
}

extension CalendarGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let day = days[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarGridDayCell", for: indexPath) as! CalendarGridDayCell
        cell.organisationColours = self.organisationColours
        cell.configure(day: day)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.didSelectDay(index: indexPath.row)
    }
}
