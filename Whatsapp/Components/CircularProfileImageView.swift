//
//  CircularProfileImageView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 19/02/25.
//

import SwiftUI
import Kingfisher

struct CircularProfileImageView: View {
    let profileImageUrl: String?
    let size: Size
    let fallbackImage: FallbackImage
    
    init(_ profileImageUrl: String? = nil, size: Size) {
        self.profileImageUrl = profileImageUrl
        self.size = size
        self.fallbackImage = .directChannelIcon
    }
    
    var body: some View {
        if let profileImageUrl {
            KFImage(URL(string: profileImageUrl))
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            placeholderImageView()
        }
    }
    
    private func placeholderImageView() -> some View {
        Image(systemName: fallbackImage.rawValue)
            .resizable()
            .scaledToFit()
            .imageScale(.large)
            .foregroundStyle(Color.placeholder)
            .frame(width: size.dimension, height: size.dimension)
            .background(Color.white)
            .clipShape(Circle())
    }
}

extension CircularProfileImageView {
    enum Size {
        case mini, xSmall, small, medium, large, extraLarge
        case custom(CGFloat)
        
        var dimension: CGFloat {
            switch self {
            case .mini:
                return 30
            case .xSmall:
                return 40
            case .small:
                return 50
            case .medium:
                return 60
            case .large:
                return 80
            case .extraLarge:
                return 120
            case .custom(let dimen):
                return dimen
            }
        }
    }
    
    enum FallbackImage: String {
        case directChannelIcon = "person.circle.fill"
        case groupChannelIcon = "person.2.circle.fill"
        
        init(for membersCount: Int) {
            switch membersCount {
            case 2:
                self = .directChannelIcon
            default:
                self = .groupChannelIcon
            }
        }
    }
}

extension CircularProfileImageView {
    init(_ channel: ChatItemModel, size: Size) {
        self.profileImageUrl = channel.coverImageUrl
        self.size = size
        self.fallbackImage = FallbackImage(for: channel.membersCount)
    }
}

#Preview {
    CircularProfileImageView(size: .large)
}
