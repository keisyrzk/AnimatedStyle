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

        apply(style: currentStyle)
    }

    //style
    private var currentStyle: Style {
        return useDarkMode ? .dark : .light
    }
    
    private var useDarkMode = false {
        didSet { apply(style: currentStyle) }
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
    
    func apply(style: Style) {
        view1.backgroundColor = style.backgroundColor
        label1.textColor = style.titleTextColor
        
        view2.backgroundColor = style.backgroundColor
        label2.textColor = style.titleTextColor
        
        view3.backgroundColor = style.backgroundColor
        label3.textColor = style.titleTextColor
    }
    
    func toggleActiveStyle() {
        useDarkMode = !useDarkMode
    }
}
