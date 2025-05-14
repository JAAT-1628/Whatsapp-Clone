//
//  MediaPickerItem_Types.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 20/02/25.
//

import SwiftUI

enum MessageMenueAction: String, CaseIterable, Identifiable {
    case reply, forword, copy, delete
    
    var id: String { return rawValue }
    var systemImage: String {
        switch self {
        case .reply:
            return "arrowshape.turn.up.left"
        case .forword:
            return "paperplane"
        case .copy:
            return "doc.on.doc"
        case .delete:
            return "trash"
        }
    }
}

enum Reaction: Int {
    case like
    case heart
    case laugh
    case shocked
    case sad
    case pray
    case more
    
    var emoji: String {
      switch self {
        case .like:
            return "👍"
        case .heart:
            return "❤️"
        case .laugh:
            return "😂"
        case .shocked:
            return "😱"
        case .sad:
            return "😢"
        case .pray:
            return "🙏"
        case .more:
            return "+"
        }
    }
}

struct VideoPickerTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { exportingFile in
            return .init(exportingFile.url)
        } importing: { receivedTransferedFile in
            let orignalFile = receivedTransferedFile.file
            let uniqueFileName = "\(UUID().uuidString).mov"
            let copiedFile = URL.documentsDirectory.appendingPathComponent(uniqueFileName)
            try FileManager.default.copyItem(at: orignalFile, to: copiedFile)
            return .init(url: copiedFile)
        }

    }
}

struct MediaAttachment: Identifiable {
    let id: String
    let type: MediaAttachmentType
    
    var thumbnail: UIImage {
        switch type {
        case .photo(let thumbnail):
            thumbnail
        case .video(let thumbnail, _):
            thumbnail
        case .audio:
            UIImage()
        }
    }
    
    var fileURL: URL? {
        switch type {
        case .photo:
            nil
        case .video(_, let fileURL):
            fileURL
        case .audio(let audioURL, _):
            audioURL
        }
    }
    
    var audioDuration: TimeInterval? {
        switch type {
        case .audio(_, let duration):
            return duration
        default:
            return nil
        }
    }
}

enum MediaAttachmentType: Equatable {
    case photo(_ thumbnail: UIImage)
    case video(_ thumbnail: UIImage, _ url: URL)
    case audio(_ url: URL, _ duration: TimeInterval)
    
    static func == (lhs: MediaAttachmentType, rhs: MediaAttachmentType) -> Bool {
        switch (lhs, rhs) {
        case (.photo, .photo), (.video, .video), (.audio, .audio):
            return true
        default:
            return false
        }
    }
}
