//
//  BoardingNavigationController.swift
//  BoardingPass
//
//  Created by Michael Skiba on 7/20/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

private struct TransitionState {
    private enum Direction {
        case Push
        case Pop
        case None
    }

    var direction: Direction = .None
    var previousState: [UIViewController]?

    init(direction: Direction, previousState: [UIViewController]) {
        self.direction = direction
        self.previousState = previousState
    }

    init() {
        direction = .None
        previousState = nil
    }
}

public class BoardingNavigationController: UINavigationController {

    private let panGestureRecognizer = UIPanGestureRecognizer()
    private var transitionState = TransitionState()
    private var interactionController: UIPercentDrivenInteractiveTransition?

    /// An optional closure that takes a `UINavigationControllerOperation` and returns a
    /// `UIViewControllerAnimatedTransitioning` object. Used to allow customization of the animation. The default value
    /// is `HorizontalSlideAnimatedTransiton.init`. Setting this value to `nil` will default to the standard
    /// navigation controller animation.
    public var animatedTransitioningProvider: (UINavigationControllerOperation -> UIViewControllerAnimatedTransitioning)? = HorizontalSlideAnimatedTransiton.init

    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configure(panGestureRecognizer, action: #selector(handlePan))
    }

}

extension BoardingNavigationController: UINavigationControllerDelegate {

    public func navigationController(navigationController: UINavigationController,
                                     animationControllerForOperation operation: UINavigationControllerOperation,
                                     fromViewController fromVC: UIViewController,
                                     toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animatedTransitioningProvider?(operation)
    }

    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

// MARK: - Actions
private extension BoardingNavigationController {
    func popToArbitrary(viewController: UIViewController, animated: Bool) {
        if !viewControllers.contains(viewController) {
            if viewControllers.count > 1 {
                viewControllers.insert(viewController,
                                       atIndex: viewControllers.endIndex.predecessor().predecessor())
            }
            else {
                viewControllers.insert(viewController, atIndex: viewControllers.startIndex)
            }
        }
        popToViewController(viewController, animated: animated)
    }

    @objc func handleSwipeRight(sender: UISwipeGestureRecognizer) {
        guard sender.state == UIGestureRecognizerState.Ended else {
            return
        }
        guard let previousViewController = (topViewController as? BoardingInformation)?.previousViewController else {
            return
        }
        popToArbitrary(previousViewController, animated: true)
    }

    @objc func handleSwipeLeft(sender: UISwipeGestureRecognizer) {
        guard sender.state == UIGestureRecognizerState.Ended else {
            return
        }
        guard let nextViewController = (topViewController as? BoardingInformation)?.nextViewController else {
            return
        }
        pushViewController(nextViewController, animated: true)
    }

    @objc func handlePan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began, .Possible:
            break
        case .Changed:
            updateAnimation(forRecognizer: sender)
        case .Ended, .Failed, .Cancelled:
            finishAnimation(forRecognizer: sender)
        }
    }
}

private extension BoardingNavigationController {

    func updateAnimation(forRecognizer recognizer: UIPanGestureRecognizer) {
        let xTranslation = recognizer.translationInView(view).x
        let percent = xTranslation / view.frame.width
        if (percent < 0 && transitionState.direction == .Pop) ||
            (percent > 0 && transitionState.direction == .Push) {
            return
        }
        if (percent > 0.66 && transitionState.direction == .Pop) ||
            (percent < -0.66 && transitionState.direction == .Push) {
            recognizer.enabled = false
            return
        }
        if interactionController == nil {
            interactionController = UIPercentDrivenInteractiveTransition()
        }
        if transitionState.direction == .None && transitioningDelegate == nil {
            if xTranslation < 0 {
                guard let pushableView = (topViewController as? BoardingInformation)?.nextViewController else {
                    return
                }
                transitionState = TransitionState(direction: .Push, previousState: viewControllers)
                pushViewController(pushableView, animated: true)
            }
            else if xTranslation > 0 {
                guard let poppableView = (topViewController as? BoardingInformation)?.previousViewController else {
                    return
                }
                transitionState = TransitionState(direction: .Pop, previousState: viewControllers)
                popToArbitrary(poppableView, animated: true)
            }
        }
        interactionController?.updateInteractiveTransition(abs(percent))
    }

    func finishAnimation(forRecognizer recognizer: UIPanGestureRecognizer) {
        recognizer.enabled = true
        let rawVelocity = recognizer.velocityInView(view).x
        let velocityPercentPerSecond: CGFloat
        switch transitionState.direction {
        case .Pop:
            velocityPercentPerSecond =  rawVelocity / view.frame.width
        case .Push:
            velocityPercentPerSecond =  -rawVelocity / view.frame.width
        case .None:
            velocityPercentPerSecond = 0
        }
        let percentComplete = interactionController?.percentComplete ?? 0
        if percentComplete > 0.5 || percentComplete + velocityPercentPerSecond > 0.75 {
            interactionController?.finishInteractiveTransition()
            interactionController = nil
            transitionState = TransitionState()
        }
        else {
            cleanUpAnimation()
        }
    }

    func cleanUpAnimation() {
        interactionController?.cancelInteractiveTransition()
        if let previousState = transitionState.previousState {
            viewControllers = previousState
        }
        interactionController = nil
        dispatch_async(dispatch_get_main_queue()) {
            self.transitionState = TransitionState()
        }
    }

    func configure(gestureRecognizer: UIGestureRecognizer, action: Selector) {
        gestureRecognizer.addTarget(self, action: action)
        view.addGestureRecognizer(gestureRecognizer)
    }

}

private extension UISwipeGestureRecognizer {

    convenience init(direction: UISwipeGestureRecognizerDirection) {
        self.init()
        self.direction = direction
    }

}
