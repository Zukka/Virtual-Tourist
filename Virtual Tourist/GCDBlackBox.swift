//
//  GCDBlackBox.swift
//  Virtual Tourist
//
//  Created by Alessandro Bellotti on 26/08/17.
//  Copyright © 2017 Alessandro Bellotti. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
