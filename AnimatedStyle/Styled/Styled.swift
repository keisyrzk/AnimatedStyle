//
//  Styled.swift
//  RxGenericDatasource
//
//  Created by Esteban on 12.09.2018.
//  Copyright © 2018 Selfcode. All rights reserved.
//

import Foundation
import UIKit

 protocol Stylable {
    func toggleActiveStyle(type: StyleType)
    func styleTransitionWillBegin()
    func styleTransitionDidEnd()
}

 extension Stylable {
    func styleTransitionWillBegin() {}
    func styleTransitionDidEnd() {}
}

enum StyleType: String {
    case Dark = "dark style"
    case Light = "light style"
}

// struct Styled {
//
//     struct Configuration {
//         let jellyFactor: Double // the bigger factor the bigger is the border deformation
//
//         init(jellyFactor: Double = 1.0) {
//            self.jellyFactor = jellyFactor
//        }
//    }
//
//     struct TransitionHandle {
//        private let coordinator: StyledTransitionCoordinator
//
//        fileprivate init(coordinator: StyledTransitionCoordinator) {
//            self.coordinator = coordinator
//        }
//
//         var panGestureRecognizer: UIPanGestureRecognizer {
//            return coordinator.panGestureRecognizer
//        }
//    }
//
//    /// window: The window that the user will pan in to trigger the
//    ///         transition.
//    /// stylableObject: An object that conforms to `GagatStyleable` and
//    ///                  which is responsible for toggling to the alternative style when
//    ///                  the transition is triggered or cancelled.
//    /// configuration: The configuration to use for the transition.
//
//     static func configure(for window: UIWindow, with stylableObject: Stylable, using configuration: Configuration = Configuration()) -> TransitionHandle {
//        let coordinator = StyledTransitionCoordinator(targetView: window, stylableObject: stylableObject, configuration: configuration)
//        return TransitionHandle(coordinator: coordinator)
//    }
//}

class Styled {
    
    static let shared = Styled()
    
    //automated change between two styles
    var useDarkMode = false {
        didSet {
            currentStyle = useDarkMode ? .Dark : .Light
        }
    }
    
    var currentStyle: StyleType = .Dark
    
    struct Configuration {
        let jellyFactor: Double // the bigger factor the bigger is the border deformation
        
        init(jellyFactor: Double = 1.0) {
            self.jellyFactor = jellyFactor
        }
    }
    
    struct TransitionHandle {
        private let coordinator: StyledTransitionCoordinator
        
        fileprivate init(coordinator: StyledTransitionCoordinator) {
            self.coordinator = coordinator
        }
        
        var panGestureRecognizer: UIPanGestureRecognizer {
            return coordinator.panGestureRecognizer
        }
    }
    
    /// window: The window that the user will pan in to trigger the
    ///         transition.
    /// stylableObject: An object that conforms to `GagatStyleable` and
    ///                  which is responsible for toggling to the alternative style when
    ///                  the transition is triggered or cancelled.
    /// configuration: The configuration to use for the transition.
    
    func configure(for window: UIWindow, with stylableObject: Stylable, using configuration: Configuration = Configuration()) -> TransitionHandle {
        let coordinator = StyledTransitionCoordinator(targetView: window, stylableObject: stylableObject, configuration: configuration)
        return TransitionHandle(coordinator: coordinator)
    }
}

