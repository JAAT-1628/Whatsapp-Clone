//
//  SettingsTabViewModel.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 24/02/25.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine
import FirebaseAuth

@MainActor
final class SettingsTabViewModel: ObservableObject {
    @Published var selectPhotoItem: PhotosPickerItem?
    @Published var profilePhoto: MediaAttachment?
    @Published var showUserInfoEditor = false
    @Published var name = ""
    @Published var bio = ""
    
    private var subscription: AnyCancellable?
    private var currentUser: UserItem
    
    var disableSaveButton: Bool { return profilePhoto == nil }
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        onPhotoPickerSelection()
    }
    
    private func onPhotoPickerSelection() {
        subscription = $selectPhotoItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoItem in
                guard let photoItem = photoItem else { return }
                self?.parsePhotoPickerItem(photoItem)
            }
    }
    
    private func parsePhotoPickerItem(_ photoItem: PhotosPickerItem) {
        Task {
            guard let data = try? await photoItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            self.profilePhoto = MediaAttachment(id: UUID().uuidString, type: .photo(uiImage))
        }
    }
    
     func uploadProfilePhoto() {
        guard let profilePhoto = profilePhoto?.thumbnail else { return }
        FirebaseHelper.uploadImage(profilePhoto, for: .profilePhoto) { [weak self] result in
            switch result {
            case .success(let imageURL):
                self?.onUploadSuccess(imageURL)
            case .failure(let error):
                print("Failed to upload profile image \(error.localizedDescription)")
            }
        } progressHandler: { error in
            print("Failed to upload profile photo \(error)")
        }
    }
    
    private func onUploadSuccess(_ imageURL: URL) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).child(.profileImageUrl).setValue(imageURL.absoluteString)
        profilePhoto = nil
        selectPhotoItem = nil
    }
    
    func updateUsernameBio() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var dict: [String: Any] = [.bio: bio]
        
        if !name.isEmptyOrWhiteSpace {
            dict[.username] = name
        }
        FirebaseConstants.UserRef.child(currentUid).updateChildValues(dict)
    }
}
