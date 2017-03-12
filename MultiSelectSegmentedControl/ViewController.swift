//
//  ViewController.swift
//  MultiSelectSegmentedControl
//
//  Created by Mihael Isaev on 12/03/2017.
//  Copyright © 2017 Mihael Isaev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MultiSelectSegmentedControlDelegate {
    
    @IBOutlet weak var days: MultiSelectSegmentedControl!
    @IBOutlet weak var simple: MultiSelectSegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        days.delegate = self
        simple.delegate = self
    }
    
    @IBAction func selectAll() {
        days.selectAllSegments(true)
        simple.selectAllSegments(true)
    }
    
    @IBAction func selectNone() {
        days.selectAllSegments(false)
        simple.selectAllSegments(false)
    }
    
    func multiSelect(multiSelectSegmendedControl: MultiSelectSegmentedControl, didChangeValue value: Bool, atIndex index: Int) {
        print("delegate value: \(value) atIndex: \(index)")
    }
}

