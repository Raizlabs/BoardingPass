//
//  ThirdViewController.swift
//  BoardingPass
//
//  Created by Michael Skiba on 7/20/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit
import BoardingPass

class ThirdViewController: ActionableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Third", comment: "Third View controller title")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        perform(animation, completion: completion, cancelation: cancellation)
    }


}

extension ThirdViewController: BackgroundColorProvider {

    var backgroundColor: UIColor {
        return .lightGrayColor()
    }

}

extension ThirdViewController: BoardingInformation {

    var nextViewController: UIViewController? {
        return CompletedViewController()
    }

}
