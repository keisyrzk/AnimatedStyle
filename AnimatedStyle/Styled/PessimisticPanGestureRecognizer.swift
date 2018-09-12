//
//  PessimisticPanGestureRecognizer.swift
//  RxGenericDatasource
//
//  Created by Esteban on 12.09.2018.
//  Copyright © 2018 Selfcode. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

/// Pan fails if the user drags fewer than the minimum number
/// of required fingers past a certain threshold (10pt).

class PessimisticPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let hasLessThanNumberOfRequiredTouches = (event.allTouches?.count ?? 0) < minimumNumberOfTouches
        let hasDraggedPastFailureThreshold = absoluteDistanceFromStartingPoint < 10.0
        if hasLessThanNumberOfRequiredTouches && hasDraggedPastFailureThreshold {
            state = .failed
        } else {
            super.touchesMoved(touches, with: event)
        }
    }
    
    private var absoluteDistanceFromStartingPoint: CGFloat {
        let translation = self.translation(in: view)
        return sqrt(pow(translation.x, 2) + pow(translation.y, 2))
    }
}
