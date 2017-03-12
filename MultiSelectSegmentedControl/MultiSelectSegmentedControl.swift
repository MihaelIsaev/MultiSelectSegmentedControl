//
//  MultiSelectSegmentedControl.swift
//  MultiSelectSegmentedControl
//
//  Created by Mihael Isaev on 12/03/2017.
//  Copyright © 2017 Mihael Isaev. All rights reserved.
//

import UIKit

public protocol MultiSelectSegmentedControlDelegate {
    func multiSelect(multiSelectSegmendedControl: MultiSelectSegmentedControl, didChangeValue value: Bool, atIndex index: Int)
}

open class MultiSelectSegmentedControl: UISegmentedControl {
    open var delegate: MultiSelectSegmentedControlDelegate?
    
    fileprivate var selectedIndexes: IndexSet = IndexSet()
    open var selectedSegmentIndexes: IndexSet {
        get {
            return selectedIndexes
        }
        set {
            if newValue.count == 0 {
                selectedIndexes = newValue
            } else {
                let validIndexes = IndexSet(integersIn: 0...numberOfSegments-1)
                selectedIndexes = validIndexes
            }
            selectSegmentsOfSelectedIndexes()
        }
    }
    open var selectedSegmentTitles: [String] {
        get {
            var titleArray: [String] = []
            for index in selectedSegmentIndexes {
                titleArray.append(titleForSegment(at: index)!)
            }
            return titleArray
        }
    }
    open var hideSeparatorBetweenSelectedSegments = false {
        didSet {
            selectSegmentsOfSelectedIndexes()
        }
    }
    fileprivate var hasBeenDrawn = false
    fileprivate var sortedSegments: [UIView] = []
    
    open func selectAllSegments(_ select: Bool) {
        selectedSegmentIndexes = select ? IndexSet(integersIn: 0...numberOfSegments) : IndexSet()
    }
    
    //MARK: Internals
    
    func initSortedSegmentsArray() {
        sortedSegments = subviews
        sortedSegments.sort { (o1, o2) -> Bool in
            let x1 = o1.frame.origin.x
            let x2 = o2.frame.origin.x
            return x1 < x2
        }
    }
    
    fileprivate func selectSegmentsOfSelectedIndexes() {
        super.selectedSegmentIndex = UISegmentedControlNoSegment
        var isPrevSelected = false
        for i in 0...numberOfSegments {
            let isSelected = selectedIndexes.contains(i)
            if sortedSegments.count > i {
                let control = sortedSegments[i]
                control.setValue(isSelected, forKey: "selected")
                if i > 0 {
                    let showBuiltinDivider = (isSelected && isPrevSelected && !hideSeparatorBetweenSelectedSegments) ? false : true
                    sortedSegments[i-1].setValue(showBuiltinDivider, forKey: "showDivider")
                }
                isPrevSelected = isSelected
            }
        }
    }
    
    internal func valueChanged() {
        let tappedSegmentIndex = super.selectedSegmentIndex
        if selectedIndexes.contains(tappedSegmentIndex) {
            selectedIndexes.remove(tappedSegmentIndex)
            delegate?.multiSelect(multiSelectSegmendedControl: self, didChangeValue: false, atIndex: tappedSegmentIndex)
        } else {
            selectedIndexes.insert(tappedSegmentIndex)
            delegate?.multiSelect(multiSelectSegmendedControl: self, didChangeValue: true, atIndex: tappedSegmentIndex)
        }
        selectSegmentsOfSelectedIndexes()
    }
    
    //MARK: Initialization
    
    fileprivate func onInit() {
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        onInit()
    }
    
    //MARK: Overrides
    
    open override func draw(_ rect: CGRect) {
        if !hasBeenDrawn {
            initSortedSegmentsArray()
            hasBeenDrawn = true
            selectSegmentsOfSelectedIndexes()
        }
        super.draw(rect)
    }
    
    open override var isMomentary: Bool {
        didSet {
            //working with momentary state
        }
    }
    
    open override var selectedSegmentIndex: Int {
        get {
            return selectedIndexes.count == 0 ? UISegmentedControlNoSegment : selectedIndexes.first!
        }
        set {
            if selectedIndexes.count == 0 {
                super.selectedSegmentIndex = newValue
            }
            selectedSegmentIndexes = newValue == UISegmentedControlNoSegment ? IndexSet() : IndexSet(integer: selectedSegmentIndex)
        }
    }
    
    fileprivate func onInsertSegmentAtIndex(segment: Int) {
        selectedIndexes.shift(startingAt: segment, by: 1)
        initSortedSegmentsArray()
    }
    
    open override func insertSegment(withTitle title: String?, at segment: Int, animated: Bool) {
        super.insertSegment(withTitle: title, at: segment, animated: animated)
    }
    
    open override func insertSegment(with image: UIImage?, at segment: Int, animated: Bool) {
        super.insertSegment(with: image, at: segment, animated: animated)
        onInsertSegmentAtIndex(segment: segment)
    }
    
    open override func removeSegment(at segment: Int, animated: Bool) {
        if numberOfSegments == 0 {
            return
        }
        var segment = segment
        if segment >= numberOfSegments {
            segment = numberOfSegments - 1
        }
        var newSelectedIndexes = selectedIndexes
        newSelectedIndexes.insert(segment)
        newSelectedIndexes.shift(startingAt: segment, by: -1)
        super.selectedSegmentIndex = segment
        super.removeSegment(at: segment, animated: animated)
        selectedIndexes = newSelectedIndexes
        let delayInSeconds: DispatchTime = DispatchTime.now() + (animated ? .milliseconds(450) : .seconds(0))
        DispatchQueue.main.asyncAfter(deadline: delayInSeconds) {
            self.initSortedSegmentsArray()
            self.selectSegmentsOfSelectedIndexes()
        }
    }
    
    open override func removeAllSegments() {
        super.selectedSegmentIndex = 0
        super.removeAllSegments()
        selectedIndexes.removeAll()
        sortedSegments = []
    }
}
