//
//  StyledNavigationController.swift
//  RxGenericDatasource
//
//  Created by Esteban on 12.09.2018.
//  Copyright © 2018 Selfcode. All rights reserved.
//

import UIKit

class StyledNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apply(Styled.shared.currentStyle)
    }
    
    private struct Style {
        var navigationBarStyle: UIBarStyle
        var statusBarStyle: UIStatusBarStyle
        
        static let dark = Style (
            navigationBarStyle: .black,
            statusBarStyle: .lightContent
        )
        
        static let light = Style (
            navigationBarStyle: .default,
            statusBarStyle: .default
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
        
        navigationBar.barStyle = style.navigationBarStyle
        UIApplication.shared.statusBarStyle = style.statusBarStyle
    }
}

extension StyledNavigationController: Stylable {
    
    func styleTransitionWillBegin() {
        // Do any work you might need to do before the transition snapshot is taken.
        if let stylableChildViewController = topViewController as? Stylable {
            stylableChildViewController.styleTransitionWillBegin()
        }
    }
    
    func styleTransitionDidEnd() {
        // Do any work you might need to do once the transition has completed.
        if let stylableChildViewController = topViewController as? Stylable {
            stylableChildViewController.styleTransitionDidEnd()
        }
    }
    
    func toggleActiveStyle(type: StyleType) {
        
        apply(type)
        
        // It's up to us to get any child view controllers to
        // toggle their active style.
        if let stylableChildViewController = topViewController as? Stylable {
            stylableChildViewController.toggleActiveStyle(type: type)
        }
    }
}
