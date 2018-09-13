//
//  NextViewController.swift
//  AnimatedStyle
//
//  Created by Esteban on 12.09.2018.
//  Copyright © 2018 Selfcode. All rights reserved.
//

import UIKit

class NextViewController: UIViewController, Stylable {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var label3: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(Styled.shared.currentStyle)
    }
}


extension NextViewController {
    
    struct Style {
        let backgroundColor: UIColor
        let titleTextColor: UIColor
        
        static let light = Style(
            backgroundColor: .gray,
            titleTextColor: .white
        )
        
        static let dark = Style(
            backgroundColor: .darkGray,
            titleTextColor: .red
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
    }
    
    func toggleActiveStyle(type: StyleType) {
        apply(type)
    }
}
