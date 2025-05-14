//
//  TimeInterval+Extension.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 21/02/25.
//

import Foundation

extension TimeInterval {
    var formatElapsedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
