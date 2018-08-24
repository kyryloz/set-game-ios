//
//  MenuViewController.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/19/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var highScoreLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        continueButton.isEnabled = UserDefaults.standard.data(forKey: "state") != nil
        highScoreLabel.text = "High Score: \(UserDefaults.standard.integer(forKey: "highScore"))"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let gameViewController = segue.destination as? GameViewController {
            switch segue.identifier {
            case "newGame":
                gameViewController.stateData = nil
            case "continue":
                gameViewController.stateData = UserDefaults.standard.data(forKey: "state")
            default:
                break
            }
        }
    }
}
