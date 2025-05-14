//
//  UIApplication+Extension.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 22/02/25.
//

import UIKit

extension UIApplication {
    static func dismissKeyboard() {
        UIApplication
            .shared
            .sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
