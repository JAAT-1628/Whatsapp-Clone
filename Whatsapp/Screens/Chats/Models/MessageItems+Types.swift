//
//  MessageItems+Types.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 18/02/25.
//

import Foundation

enum MessageAdminType: String {
    case channelCreation
    case memberAdded
    case memberLeft
    case channelNameChanged
}

enum MessageType: Hashable {
    case admin(_ type: MessageAdminType), text, photo, video, audio
    
    var title: String {
        switch self {
        case .admin:
            "admin"
        case .text:
            "text"
        case .photo:
            "photo"
        case .video:
            "video"
        case .audio:
            "audio"
        }
    }
    
    var isAdminMessage: Bool {
        if case .admin = self {
            return true
        } else {
            return false
        }
    }
    
    var iconName: String {
        switch self {
        case .admin:
            return "megaphone.fill"
        case .text:
            return ""
        case .photo:
            return "photo.fill"
        case .video:
            return "video.fill"
        case .audio:
            return "mic.fill"
        }
    }
    
    init?(_ stringValue: String) {
        switch stringValue {
        case "text":
            self = .text
            
        case "photo":
            self = .photo
            
        case "video":
            self = .video
            
        case "audio":
            self = .audio
            
        default:
            if let adminMesageType = MessageAdminType(rawValue: stringValue) {
                self = .admin(adminMesageType)
            } else {
                return nil
            }
        }
    }
}

extension MessageType: Equatable {
    static func ==(lhs: MessageType, rhs: MessageType) -> Bool {
        switch (lhs, rhs) {
        case (.admin(let leftAdmin), .admin(let rightAdmin)):
            return leftAdmin == rightAdmin
            
        case (.text, .text),
            (.photo, .photo),
            (.video, .video),
            (.audio, .audio):
            return true
            
        default:
            return false
        }
    }
}

enum MessageDirection {
    case sent, received
    
    //for debugging
    static var random: MessageDirection {
        return [MessageDirection.sent, .received].randomElement() ?? .sent
    }
}
