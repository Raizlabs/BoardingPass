//
//  CompletedViewController.swift
//  BoardingPass
//
//  Created by Michael Skiba on 7/20/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit
import BoardingPass

class CompletedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = NSLocalizedString("Completed", comment: "completed onboarding title")
        let resetButton = UIButton(title: NSLocalizedString("Reset", comment: "Reset button title"), font: UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1))
        resetButton.addTarget(self, action: #selector(handleResetTapped), forControlEvents: .TouchUpInside)
        view.addSubview(resetButton)
        let constraints: [NSLayoutConstraint] = [
            resetButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
            bottomLayoutGuide.topAnchor.constraintEqualToAnchor(resetButton.bottomAnchor, constant: 10),
            ]
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(constraints)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        performAlongsideCurrentCoordinator(animation, cancelation: cancellation)
    }
}

extension CompletedViewController: BackgroundColorProvider {

    var backgroundColor: UIColor {
        return .whiteColor()
    }

    var currentProgress: NSProgress {
        return NSProgress(completedUnitCount: 4, totalUnitCount: 4)
    }

}

private extension CompletedViewController {
    @objc func handleResetTapped(sender: UIButton) {
        let origin = FirstViewController()
        navigationController?.viewControllers.insert(origin, atIndex: 0)
        navigationController?.popToViewController(origin, animated: true)
    }
}
