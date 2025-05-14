//
//  PublicChanelItemModel.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 25/02/25.
//

import Foundation

struct PublicChanelItemModel: Identifiable {
    let imageUrl: String
    let title: String
    
    var id: String { return title }
    
    static let placeholders: [PublicChanelItemModel] = [
        .init(imageUrl: "", title: "UFC")
    ]
}
