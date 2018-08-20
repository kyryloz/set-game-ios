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
    
    override func viewDidAppear(_ animated: Bool) {
        continueButton.isEnabled = UserDefaults.standard.data(forKey: "state") != nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
