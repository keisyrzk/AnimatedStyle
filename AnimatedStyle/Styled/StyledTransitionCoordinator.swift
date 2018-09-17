//
//  StyledTransitionCoordinator.swift
//  RxGenericDatasource
//
//  Created by Esteban on 12.09.2018.
//  Copyright © 2018 Selfcode. All rights reserved.
//

import Foundation
import UIKit

class StyledTransitionCoordinator: NSObject {
    
    fileprivate enum State {
        case idle
        case tracking
        case transitioning
    }
    
    /// The view (or window) that the transition should occur in, and
    /// which the pan gesture recognizer is installed in.
    fileprivate let targetView: UIView
    
    fileprivate let configuration: Styled.Configuration
    private let stylableObject: Stylable
    
    private(set) var panGestureRecognizer: PessimisticPanGestureRecognizer!
    private var chosenDirection: PanDirection = .down
    
    fileprivate var state = State.idle
    
    init(targetView: UIView, stylableObject: Stylable, configuration: Styled.Configuration) {
        self.targetView = targetView
        self.configuration = configuration
        self.stylableObject = stylableObject
        
        super.init()
        
        setupPanGestureRecognizer(in: targetView)
    }
    
    deinit {
        panGestureRecognizer.view?.removeGestureRecognizer(panGestureRecognizer)
    }
    
    // Pan gesture recognizer
    
    private func setupPanGestureRecognizer(in targetView: UIView) {
        let panGestureRecognizer = PessimisticPanGestureRecognizer(target: self, action: #selector(panRecognizerDidChange(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        targetView.addGestureRecognizer(panGestureRecognizer)
        
        self.panGestureRecognizer = panGestureRecognizer
    }
    
    @objc func panRecognizerDidChange(_ panRecognizer: PessimisticPanGestureRecognizer) {
        switch panRecognizer.state {
        case .began:
            beginInteractiveStyleTransition(withPanRecognizer: panRecognizer)
        case .changed:
            adjustMaskLayer(basedOn: panRecognizer)
        case .ended, .failed:
            endInteractiveStyleTransition(withPanRecognizer: panRecognizer)
        case .cancelled:
            cancelInteractiveStyleTransitionWithoutAnimation()
        default: break
        }
    }
    
    // Interactive style transition
    
    /// During the interactive transition, this property contains a
    /// snapshot of the view when it was styled with the previous style
    /// (i.e. the style we're transitioning _from_).
    /// As the transition progresses, less and less of the snapshot view
    /// will be visible, revealing more of the real view which is styled
    /// with the new style.
    private var previousStyleTargetViewSnapshot: UIView?
    
    /// During the interactive transition, this property contains the layer
    /// used to mask the contents of `previousStyleTargetViewSnapshot`.
    /// When the user pans, the position and path of `snapshotMaskLayer` is
    /// adjusted to reflect the current translation of the pan recognizer.
    private var snapshotMaskLayer: CAShapeLayer?
    
    private func beginInteractiveStyleTransition(withPanRecognizer panRecognizer: PessimisticPanGestureRecognizer) {
        
        // Inform our object that we're about to start a transition.
        stylableObject.styleTransitionWillBegin()
        
        // We snapshot the targetView before applying the new style, and make sure
        // it's positioned on top of all the other content.
        previousStyleTargetViewSnapshot = targetView.snapshotView(afterScreenUpdates: false)
        targetView.addSubview(previousStyleTargetViewSnapshot!)
        targetView.bringSubview(toFront: previousStyleTargetViewSnapshot!)
        
        // When we have the snapshot we create a new mask layer that's used to
        // control how much of the previous view we display as the transition
        // progresses.
        snapshotMaskLayer = CAShapeLayer()
        snapshotMaskLayer?.path = UIBezierPath(rect: targetView.bounds).cgPath
        snapshotMaskLayer?.fillColor = UIColor.black.cgColor
        previousStyleTargetViewSnapshot?.layer.mask = snapshotMaskLayer
        
        // Now we're free to apply the new style. This won't be visible until
        // the user pans more since the snapshot is displayed on top of the
        // actual content.
        Styled.shared.useDarkMode = !Styled.shared.useDarkMode  //automated change between two styles
        stylableObject.toggleActiveStyle(type: Styled.shared.currentStyle)
        
        // Finally we make our first adjustment to the mask layer based on the
        // values of the pan recognizer.
        adjustMaskLayer(basedOn: panRecognizer)
        
        state = .tracking
    }
    
    private func adjustMaskLayer(basedOn panRecognizer: PessimisticPanGestureRecognizer) {
        adjustMaskLayerPosition(basedOn: panRecognizer)
        adjustMaskLayerPath(basedOn: panRecognizer)
    }
    
    private func adjustMaskLayerPosition(basedOn panRecognizer: PessimisticPanGestureRecognizer) {
        // We need to disable implicit animations since we don't want to
        // animate the position change of the mask layer.
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        switch chosenDirection {

        case .down:
            let verticalTranslation = panRecognizer.translation(in: targetView).y
            if verticalTranslation < targetView.frame.minY {
                panRecognizer.setTranslation(.zero, in: targetView)
                snapshotMaskLayer?.frame.origin.y = targetView.frame.minY
            } else {
                snapshotMaskLayer?.frame.origin.y = verticalTranslation
            }

        case .up:
            let verticalTranslation = panRecognizer.translation(in: targetView).y
            if verticalTranslation > targetView.frame.maxY {
                panRecognizer.setTranslation(.zero, in: targetView)
                snapshotMaskLayer?.frame.origin.y = targetView.frame.maxY
            } else {
                snapshotMaskLayer?.frame.origin.y = verticalTranslation
            }

        case .left:
            let horizontalTranslation = panRecognizer.translation(in: targetView).x
            if horizontalTranslation > targetView.frame.maxX {
                panRecognizer.setTranslation(.zero, in: targetView)
                snapshotMaskLayer?.frame.origin.x = targetView.frame.maxX
            } else {
                snapshotMaskLayer?.frame.origin.x = horizontalTranslation
            }

        case .right:
            let horizontalTranslation = panRecognizer.translation(in: targetView).x
            if horizontalTranslation < targetView.frame.minX {
                panRecognizer.setTranslation(.zero, in: targetView)
                snapshotMaskLayer?.frame.origin.x = targetView.frame.minX
            } else {
                snapshotMaskLayer?.frame.origin.x = horizontalTranslation
            }
        }

        CATransaction.commit()
    }
    
    private func adjustMaskLayerPath(basedOn panRecognizer: PessimisticPanGestureRecognizer) {
        let maskingPath = UIBezierPath()

        switch chosenDirection {

        case .down:
            // Top-left corner...
            maskingPath.move(to: CGPoint(x: targetView.frame.minX, y: targetView.bounds.minY))

            // ...arc to top-right corner..
            let damping = configuration.jellyFactor > 0.0 ? CGFloat(45.0 / configuration.jellyFactor) : 0.0
            let verticalOffset = damping > 0.0 ? panRecognizer.velocity(in: targetView).y / damping : 0.0
            let horizontalTouchLocation = panRecognizer.location(in: targetView).x
            maskingPath.addQuadCurve(to: CGPoint(x: targetView.bounds.maxX, y: targetView.frame.minY), controlPoint: CGPoint(x: horizontalTouchLocation, y: verticalOffset))

            // ...to bottom-right corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.maxX, y: targetView.bounds.maxY))

            // ...to bottom-left corner...
            maskingPath.addLine(to: CGPoint(x: targetView.frame.minX, y: targetView.bounds.maxY))

            // ...and close the path.
            maskingPath.close()

        case .up:
            // bottom-left corner...
            maskingPath.move(to: CGPoint(x: targetView.frame.minX, y: targetView.frame.maxY))

            // ...arc to bottom-right corner..
            let damping = configuration.jellyFactor > 0.0 ? CGFloat(45.0 / configuration.jellyFactor) : 0.0
            let verticalOffset = damping > 0.0 ? panRecognizer.velocity(in: targetView).y / damping : 0.0
            let horizontalTouchLocation = panRecognizer.location(in: targetView).x
            maskingPath.addQuadCurve(to: CGPoint(x: targetView.bounds.maxX, y: targetView.frame.maxY), controlPoint: CGPoint(x: horizontalTouchLocation, y: UIScreen.main.bounds.height - verticalOffset))

            // ...to top-right corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.maxX, y: targetView.bounds.minY))

            // ...to top-left corner...
            maskingPath.addLine(to: CGPoint(x: targetView.frame.minX, y: targetView.bounds.minY))

            // ...and close the path.
            maskingPath.close()

        case .left:
            // bottom-right corner...
            maskingPath.move(to: CGPoint(x: targetView.frame.maxX, y: targetView.frame.maxY))

            // ...arc to top-right corner...
            let damping = configuration.jellyFactor > 0.0 ? CGFloat(45.0 / configuration.jellyFactor) : 0.0
            let horizontalOffset = damping > 0.0 ? panRecognizer.velocity(in: targetView).x / damping : 0.0
            let verticalTouchLocation = panRecognizer.location(in: targetView).y
            maskingPath.addQuadCurve(to: CGPoint(x: targetView.frame.maxX, y: targetView.bounds.minY), controlPoint: CGPoint(x: UIScreen.main.bounds.width - horizontalOffset, y: verticalTouchLocation))

            // ...to top-left corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.minX, y: targetView.bounds.minY))

            // ...to bottom-left corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.minX, y: targetView.frame.maxY))

            // ...and close the path.
            maskingPath.close()

        case .right:
            // bottom-left corner...
            maskingPath.move(to: CGPoint(x: targetView.frame.minX, y: targetView.frame.maxY))

            // ...arc to top-left corner...
            let damping = configuration.jellyFactor > 0.0 ? CGFloat(45.0 / configuration.jellyFactor) : 0.0
            let horizontalOffset = damping > 0.0 ? panRecognizer.velocity(in: targetView).x / damping : 0.0
            let verticalTouchLocation = panRecognizer.location(in: targetView).y
            maskingPath.addQuadCurve(to: CGPoint(x: targetView.frame.minX, y: targetView.bounds.minY), controlPoint: CGPoint(x: horizontalOffset, y: verticalTouchLocation))

            // ...to top-right corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.maxX, y: targetView.bounds.minY))

            // ...to bottom-right corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.maxX, y: targetView.frame.maxY))

            // ...and close the path.
            maskingPath.close()
        }

        snapshotMaskLayer?.path = maskingPath.cgPath
    }
    
    private func endInteractiveStyleTransition(withPanRecognizer panRecognizer: PessimisticPanGestureRecognizer) {
        let velocity = panRecognizer.velocity(in: targetView)
        let translation = panRecognizer.translation(in: targetView)
        
        let hasPassedDownThreshold = translation.y > targetView.bounds.midY
        let hasPassedUpThreshold = translation.y < targetView.bounds.midY
        let hasPassedRightThreshold = translation.x > targetView.bounds.midX
        let hasPassedLeftThreshold = translation.x < targetView.bounds.midX
        
        let goDown = chosenDirection == .down && hasPassedDownThreshold
        let goUp = chosenDirection == .up && hasPassedUpThreshold
        let goRight = chosenDirection == .right && hasPassedRightThreshold
        let goLeft = chosenDirection == .left && hasPassedLeftThreshold
        
        
        // We support both completing the transition and cancelling the transition.
        // The transition to the new style should be completed if the user is panning
        // downwards or if they've panned enough that more than half of the new view
        // is already shown.
        let shouldCompleteTransition = goDown || goUp || goLeft || goRight

        if shouldCompleteTransition {
            completeInteractiveStyleTransition(withVelocity: velocity)
        } else {
            cancelInteractiveStyleTransition(withVelocity: velocity)
        }
    }
    
    private func cancelInteractiveStyleTransitionWithoutAnimation() {
        stylableObject.toggleActiveStyle(type: Styled.shared.currentStyle)
        cleanupAfterInteractiveStyleTransition()
        state = .idle
        stylableObject.styleTransitionDidEnd()
    }
    
    private func cancelInteractiveStyleTransition(withVelocity velocity: CGPoint) {
        guard let snapshotMaskLayer = snapshotMaskLayer else {
            return
        }
        
        state = .transitioning
        
        // When cancelling the transition we simply animate the mask layer to its original
        // location (which means that the entire previous style snapshot is shown), then
        // reset the style to the previous style and remove the snapshot.
        Styled.shared.useDarkMode = !Styled.shared.useDarkMode
        animate(snapshotMaskLayer, to: .zero, withVelocity: velocity) {
            self.stylableObject.toggleActiveStyle(type: Styled.shared.currentStyle)
            self.cleanupAfterInteractiveStyleTransition()
            self.state = .idle
            self.stylableObject.styleTransitionDidEnd()
        }
    }
    
    private func completeInteractiveStyleTransition(withVelocity velocity: CGPoint) {
        guard let snapshotMaskLayer = snapshotMaskLayer else {
            return
        }
        
        state = .transitioning
        
        // When completing the transition we slide the mask layer down to the bottom of
        // the targetView and then remove the snapshot. The further down the mask layer is,
        // the more of the underlying view is visible. When the mask layer reaches the
        // bottom of the targetView, the entire underlying view will be visible so removing
        // the snapshot will have no visual effect.
        var targetLocation = CGPoint(x: 0.0, y: 0.0)
        
        switch chosenDirection {
        case .down:
            targetLocation = CGPoint(x: 0.0, y: targetView.bounds.maxY)
        case .up:
            targetLocation = CGPoint(x: 0.0, y: -targetView.bounds.maxY)
        case .right:
            targetLocation = CGPoint(x: targetView.frame.maxX, y: 0.0)
        case .left:
            targetLocation = CGPoint(x: -targetView.frame.maxX, y: 0.0)
        }
        
        animate(snapshotMaskLayer, to: targetLocation, withVelocity: velocity) {
            self.cleanupAfterInteractiveStyleTransition()
            self.state = .idle
            self.stylableObject.styleTransitionDidEnd()
        }
    }
    
    
    
    // AUTOMATED ANIMATION
    
    private func adjustMaskLayerPath(shouldApplyRandomCurve: Bool) {
        let maskingPath = UIBezierPath()
        
        let hillHeight: CGFloat = 100
        let hillPosX: CGFloat = UIScreen.main.bounds.width/2
        let hillPosY: CGFloat = UIScreen.main.bounds.height/2
        
        switch chosenDirection {
            
        case .down:
            // Top-left corner...
            maskingPath.move(to: CGPoint(x: targetView.frame.minX, y: targetView.bounds.minY))
            
            // ...arc to top-right corner..
            maskingPath.addRandomCurve(to: CGPoint(x: targetView.bounds.maxX, y: targetView.frame.minY))
//            maskingPath.addQuadCurve(to: CGPoint(x: targetView.bounds.maxX, y: targetView.frame.minY), controlPoint: CGPoint(x: hillPosX, y: hillHeight))

            // ...to bottom-right corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.maxX, y: targetView.bounds.maxY))
            
            // ...to bottom-left corner...
            maskingPath.addLine(to: CGPoint(x: targetView.frame.minX, y: targetView.bounds.maxY))
            
            // ...and close the path.
            maskingPath.close()
            
        case .up:
            // bottom-left corner...
            maskingPath.move(to: CGPoint(x: targetView.frame.minX, y: targetView.frame.maxY))
            
            // ...arc to bottom-right corner..
            maskingPath.addQuadCurve(to: CGPoint(x: targetView.bounds.maxX, y: targetView.frame.maxY), controlPoint: CGPoint(x: hillPosX, y: UIScreen.main.bounds.height - hillHeight))
            
            // ...to top-right corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.maxX, y: targetView.bounds.minY))
            
            // ...to top-left corner...
            maskingPath.addLine(to: CGPoint(x: targetView.frame.minX, y: targetView.bounds.minY))
            
            // ...and close the path.
            maskingPath.close()
            
        case .left:
            // bottom-right corner...
            maskingPath.move(to: CGPoint(x: targetView.frame.maxX, y: targetView.frame.maxY))
            
            // ...arc to top-right corner...
            maskingPath.addQuadCurve(to: CGPoint(x: targetView.frame.maxX, y: targetView.bounds.minY), controlPoint: CGPoint(x: UIScreen.main.bounds.width - hillHeight, y: hillPosY))
            
            // ...to top-left corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.minX, y: targetView.bounds.minY))
            
            // ...to bottom-left corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.minX, y: targetView.frame.maxY))
            
            // ...and close the path.
            maskingPath.close()
            
        case .right:
            // bottom-left corner...
            maskingPath.move(to: CGPoint(x: targetView.frame.minX, y: targetView.frame.maxY))
            
            // ...arc to top-left corner...
            maskingPath.addQuadCurve(to: CGPoint(x: targetView.frame.minX, y: targetView.bounds.minY), controlPoint: CGPoint(x: hillHeight, y: hillPosY))
            
            // ...to top-right corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.maxX, y: targetView.bounds.minY))
            
            // ...to bottom-right corner...
            maskingPath.addLine(to: CGPoint(x: targetView.bounds.maxX, y: targetView.frame.maxY))
            
            // ...and close the path.
            maskingPath.close()
        }
        
        snapshotMaskLayer?.path = maskingPath.cgPath
    }
    
    func performAniamtion(shouldApplyRandomCurve: Bool) {
        
        stylableObject.styleTransitionWillBegin()
        
        previousStyleTargetViewSnapshot = targetView.snapshotView(afterScreenUpdates: false)
        targetView.addSubview(previousStyleTargetViewSnapshot!)
        targetView.bringSubview(toFront: previousStyleTargetViewSnapshot!)
        
        snapshotMaskLayer = CAShapeLayer()
        snapshotMaskLayer?.path = UIBezierPath(rect: targetView.bounds).cgPath
        snapshotMaskLayer?.fillColor = UIColor.black.cgColor
        previousStyleTargetViewSnapshot?.layer.mask = snapshotMaskLayer
        
        Styled.shared.useDarkMode = !Styled.shared.useDarkMode  //automated change between two styles
        stylableObject.toggleActiveStyle(type: Styled.shared.currentStyle)
        
        adjustMaskLayerPath(shouldApplyRandomCurve: shouldApplyRandomCurve)
        
        state = .tracking
        
        guard let snapshotMaskLayer = snapshotMaskLayer else {
            return
        }
        
        state = .transitioning
        
        var targetLocation = CGPoint(x: 0.0, y: 0.0)
        
        switch chosenDirection {
        case .down:
            targetLocation = CGPoint(x: 0.0, y: targetView.bounds.maxY)
        case .up:
            targetLocation = CGPoint(x: 0.0, y: -targetView.bounds.maxY)
        case .right:
            targetLocation = CGPoint(x: targetView.frame.maxX, y: 0.0)
        case .left:
            targetLocation = CGPoint(x: -targetView.frame.maxX, y: 0.0)
        }
        
        animate(snapshotMaskLayer, to: targetLocation, withVelocity: .zero) {
            self.cleanupAfterInteractiveStyleTransition()
            self.state = .idle
            self.stylableObject.styleTransitionDidEnd()
        }
    }
    
    private func cleanupAfterInteractiveStyleTransition() {
        self.previousStyleTargetViewSnapshot?.removeFromSuperview()
        self.previousStyleTargetViewSnapshot = nil
        self.snapshotMaskLayer = nil
    }
}

extension StyledTransitionCoordinator: UIGestureRecognizerDelegate {
    private typealias Degrees = Double
    
    private enum PanDirection {
        case up, down, left, right
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panRecognizer = gestureRecognizer as? PessimisticPanGestureRecognizer else {
            return true
        }
        
        guard state == .idle else {
            return false
        }
        
        let translation = panRecognizer.translation(in: targetView)
        let panningAngle: Degrees = atan2(Double(translation.y), Double(translation.x)) * 360 / (Double.pi * 2)
        let panningDirection = direction(for: panningAngle)
        
        return panningDirection == chosenDirection
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // This prevents other pan gesture recognizerns (such as the one in scroll views) from interfering with the this gesture.
        return otherGestureRecognizer is UIPanGestureRecognizer
    }
    
    private func direction(for angle: Degrees) -> PanDirection {
        switch angle {
        case 45.0...135.0: return .down
        case 135.0...225.0: return .left
        case 225.0...315.0: return .up
        default: return .right
        }
    }
}
