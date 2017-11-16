//
//  UIDevice+Extensions.swift
//  MyBricks
//
//  Created by Leif Harrison on 11/16/17.
//  Copyright © 2017 Catsreach. All rights reserved.
//

import UIKit

extension UIDevice {

    static var isSimulator: Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }

}
