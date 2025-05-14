//
//  String+Extension.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 18/02/25.
//

import Foundation

extension String {
    var isEmptyOrWhiteSpace: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}
