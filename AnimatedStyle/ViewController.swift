//
//  ViewController.swift
//  AnimatedStyle
//
//  Created by Esteban on 12.09.2018.
//  Copyright © 2018 Selfcode. All rights reserved.
//

import UIKit

class ViewController: UIViewController, Stylable {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var label3: UILabel!
        
    @IBOutlet weak var segemnedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(Styled.shared.currentStyle)
    }
    
    @IBAction func changeStyle(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.transitionHandle.coordinator.performAniamtion(shouldApplyRandomCurve: true)
    }
    
    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {
        
        let coordinator = (UIApplication.shared.delegate as! AppDelegate).transitionHandle.coordinator
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            coordinator.chosenDirection = .down
        case 1:
            coordinator.chosenDirection = .up
        case 2:
            coordinator.chosenDirection = .right
        case 3:
            coordinator.chosenDirection = .left
        default:
            break
        }
    }
}

extension ViewController {
    
    struct Style {
        let backgroundColor: UIColor
        let titleTextColor: UIColor
        let segmentedTint: UIColor
        
        static let light = Style(
            backgroundColor: .white,
            titleTextColor: .black,
            segmentedTint: .darkGray
        )
        
        static let dark = Style(
            backgroundColor: UIColor(white: 0.2, alpha: 1.0),
            titleTextColor: .orange,
            segmentedTint: .orange
        )
    }
    
    private func apply(_ type: StyleType) {
        
        var style: Style
        
        switch type {
            
        case .Dark:
            style = .dark
        case .Light:
            style = .light
        }
        
        view1.backgroundColor = style.backgroundColor
        label1.textColor = style.titleTextColor
        
        view2.backgroundColor = style.backgroundColor
        label2.textColor = style.titleTextColor
        
        view3.backgroundColor = style.backgroundColor
        label3.textColor = style.titleTextColor
        
        self.view.backgroundColor = style.backgroundColor
        
        segemnedControl.tintColor = style.segmentedTint
    }
    
    func toggleActiveStyle(type: StyleType) {
        apply(type)
    }
}
