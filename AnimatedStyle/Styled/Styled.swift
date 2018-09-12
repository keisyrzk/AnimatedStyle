//
//  Styled.swift
//  RxGenericDatasource
//
//  Created by Esteban on 12.09.2018.
//  Copyright © 2018 Selfcode. All rights reserved.
//

import Foundation
import UIKit

public protocol Stylable {

    func toggleActiveStyle()
    func styleTransitionWillBegin()
    func styleTransitionDidEnd()
}

public extension Stylable {
    func styleTransitionWillBegin() {}
    func styleTransitionDidEnd() {}
}

public struct Styled {
    
    public struct Configuration {
        public let jellyFactor: Double // the bigger factor the bigger is the border deformation
        
        public init(jellyFactor: Double = 1.0) {
            self.jellyFactor = jellyFactor
        }
    }
    
    public struct TransitionHandle {
        private let coordinator: StyledTransitionCoordinator
        
        fileprivate init(coordinator: StyledTransitionCoordinator) {
            self.coordinator = coordinator
        }
        
        public var panGestureRecognizer: UIPanGestureRecognizer {
            return coordinator.panGestureRecognizer
        }
    }
    
    /// window: The window that the user will pan in to trigger the
    ///         transition.
    /// styleableObject: An object that conforms to `GagatStyleable` and
    ///                  which is responsible for toggling to the alternative style when
    ///                  the transition is triggered or cancelled.
    /// configuration: The configuration to use for the transition.

    public static func configure(for window: UIWindow, with styleableObject: Stylable, using configuration: Configuration = Configuration()) -> TransitionHandle {
        let coordinator = StyledTransitionCoordinator(targetView: window, styleableObject: styleableObject, configuration: configuration)
        return TransitionHandle(coordinator: coordinator)
    }
}
