//
//  MessageListController.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import Foundation
import UIKit
import SwiftUI
import Combine

final class MessageListController: UIViewController {
    
    //MARK: View's lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        messageCollectionView.backgroundColor = .clear
        view.backgroundColor = .clear
        setUpViews()
        SetUpMessageListners()
        setupLongPressGesture()
    }
    
    init(_ vm: ChatRoomViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: properties
    private let vm: ChatRoomViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let cellIdentifier = "MessageListController"
    private var lastScrollPosition: String?
    
    //MARK: reaction properties
    private var startingFrame: CGRect?
    private var blurView: UIVisualEffectView?
    private var focusedView: UIView?
    private var highlightedCell: UICollectionViewCell?
    private var reactionHostVC: UIViewController?
    private var menueHostVC: UIViewController?
    
    private lazy var pullToRefresh: UIRefreshControl = {
        let pullToRefresh = UIRefreshControl()
        pullToRefresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return pullToRefresh
    }()
    
    private let compositionLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
        var listConfing = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfing.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        listConfing.showsSeparators = false
        let section = NSCollectionLayoutSection.list(using: listConfing, layoutEnvironment: layoutEnvironment)
        section.contentInsets.leading = 0
        section.contentInsets.trailing = 0
        section.interGroupSpacing = -6
        return section
    }
    
    private lazy var messageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.refreshControl = pullToRefresh
        return collectionView
    }()
    
    private let backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(image: .chatbackground)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImageView
    }()
    
    private let pullDownHUDView: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        var imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .black)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfig)
        buttonConfig.image = image
        buttonConfig.baseBackgroundColor = .bubbleGreen
        buttonConfig.baseForegroundColor = .whatsAppBlack
        buttonConfig.imagePadding = 5
        buttonConfig.cornerStyle = .capsule
        let font = UIFont.systemFont(ofSize: 12, weight: .black)
        buttonConfig.attributedTitle = AttributedString("Old Messages", attributes: AttributeContainer([NSAttributedString.Key.font: font]))
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()
    
    //MARK: methods
    private func setUpViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(messageCollectionView)
        view.addSubview(pullDownHUDView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            messageCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            messageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            pullDownHUDView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pullDownHUDView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func SetUpMessageListners() {
        let delay = 200
        vm.$messages
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.messageCollectionView.reloadData()
            }.store(in: &subscriptions)
        
        vm.$scrollToBottomRequest
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.messageCollectionView.scrollToLastItem(at: .bottom, animated: scrollRequest.isAnimated)
                }
            }.store(in: &subscriptions)
        
        vm.$isPaginating
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] isPaginating in
                guard let self = self, let lastScrollPosition else { return }
                if isPaginating == false {
                    guard let index = vm.messages.firstIndex(where: { $0.id == lastScrollPosition }) else { return }
                    let indexPath = IndexPath(item: index, section: 0)
                    self.messageCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    self.pullToRefresh.endRefreshing()
                }
            }.store(in: &subscriptions)
    }
    
    @objc private func refreshData() {
        lastScrollPosition = vm.messages.first?.id
        vm.paginateMoreMessages()
    }
}

extension MessageListController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let message = vm.messages[indexPath.item]
        let isNewDay = vm.isNewDay(for: message, at: indexPath.item)
        let showSenderName = vm.showSendrName(for: message, at: indexPath.item)
        cell.backgroundColor = .clear
        cell.contentConfiguration = UIHostingConfiguration {
            BubbleView(message: message, channel: vm.channel, isNewDay: isNewDay, showSenderName: showSenderName)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIApplication.dismissKeyboard()
        let messageItem = vm.messages[indexPath.row]
        switch messageItem.type {
        case .video:
            guard let videoURLString = messageItem.videoURL,
                  let videoURL = URL(string: videoURLString)
            else { return }
            vm.showMediaPlayer(videoURL)
        default:
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            pullDownHUDView.alpha = vm.isPaginatable ? 1 : 0
        } else {
            pullDownHUDView.alpha = 0
        }
    }
}

extension MessageListController {
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showContextMenue))
        longPressGesture.minimumPressDuration = 0.5
        messageCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func showContextMenue(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: messageCollectionView)
        guard let indexPath = messageCollectionView.indexPathForItem(at: point) else { return }
        let message = vm.messages[indexPath.item]
        guard message.type.isAdminMessage == false else { return }
        
        guard let selectedCell = messageCollectionView.cellForItem(at: indexPath) else { return }
        Haptic.impact(.heavy)
        startingFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil)
        guard let snapshotCell = selectedCell.snapshotView(afterScreenUpdates: false) else { return }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissContextMenue))
        focusedView = UIView(frame: startingFrame ?? .zero)
        guard let focusedView else { return }
        focusedView.isUserInteractionEnabled = false
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        guard let blurView else { return }
        blurView.contentView.isUserInteractionEnabled = true
        blurView.contentView.addGestureRecognizer(tapGesture)
        blurView.alpha = 0
        highlightedCell = selectedCell
        highlightedCell?.alpha = 0
        
        guard let keyWindow = UIWindowScene.current?.keyWindow else { return }
        keyWindow.addSubview(blurView)
        keyWindow.addSubview(focusedView)
        focusedView.addSubview(snapshotCell)
        blurView.frame = keyWindow.frame
        
        let isNewDay = vm.isNewDay(for: message, at: indexPath.item)
        attachMenueActionItems(to: message, in: keyWindow, isNewDay)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) {
            blurView.alpha = 1
            focusedView.center.y = keyWindow.center.y - 60
            snapshotCell.frame = focusedView.bounds
            snapshotCell.layer.shadowColor = UIColor.gray.cgColor
            snapshotCell.layer.shadowOpacity = 0.4
            snapshotCell.layer.shadowOffset = .init(width: 0, height: 2)
            snapshotCell.layer.shadowRadius = 4
        }
    }
    
    private func attachMenueActionItems(to message: MessageItems, in window: UIWindow, _ isNewDay: Bool) {
        guard let focusedView else { return }
        let chatReactionView = ChatReactionView(message: message) { [weak self] reaction in
            self?.dismissContextMenue()
            self?.vm.addReaction(reaction, to: message)
        }
        let reactionHostVC = UIHostingController(rootView: chatReactionView)
        reactionHostVC.view.backgroundColor = .clear
        reactionHostVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        let reactionPadding: CGFloat = isNewDay ? 55 : 5
        
        window.addSubview(reactionHostVC.view)
        reactionHostVC.view.bottomAnchor.constraint(equalTo: focusedView.topAnchor, constant: reactionPadding).isActive = true
        reactionHostVC.view.leadingAnchor.constraint(equalTo: focusedView.leadingAnchor, constant: 20).isActive = message.direction == .received
        reactionHostVC.view.trailingAnchor.constraint(equalTo: focusedView.trailingAnchor, constant: -20).isActive = message.direction == .sent
        
        let messageMenuView = MessageMenuView(message: message)
        let menueHostVC = UIHostingController(rootView: messageMenuView)
        menueHostVC.view.backgroundColor = .clear
        menueHostVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        window.addSubview(menueHostVC.view)
        menueHostVC.view.topAnchor.constraint(equalTo: focusedView.bottomAnchor, constant: 0).isActive = true
        reactionHostVC.view.leadingAnchor.constraint(equalTo: focusedView.leadingAnchor, constant: 20).isActive = message.direction == .received
        reactionHostVC.view.trailingAnchor.constraint(equalTo: focusedView.trailingAnchor, constant: -20).isActive = message.direction == .sent
        
        self.reactionHostVC = reactionHostVC
        self.menueHostVC = menueHostVC
    }
    
    @objc private func dismissContextMenue() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let self = self else { return }
            focusedView?.frame = startingFrame ?? .zero
            reactionHostVC?.view.removeFromSuperview()
            menueHostVC?.view.removeFromSuperview()
            blurView?.alpha = 0
        } completion: { [weak self] _ in
            self?.highlightedCell?.alpha = 1
            self?.blurView?.removeFromSuperview()
            self?.focusedView?.removeFromSuperview()
            
            //clearing refrences
            self?.highlightedCell = nil
            self?.blurView = nil
            self?.focusedView = nil
            self?.reactionHostVC = nil
            self?.menueHostVC = nil
        }
    }
}

private extension UICollectionView {
    func scrollToLastItem(at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard numberOfItems(inSection: numberOfSections - 1) > 0 else { return }
        
        let lastSectionIndex = numberOfSections - 1
        let lastRowIndex = numberOfItems(inSection: lastSectionIndex) - 1
        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        scrollToItem(at: lastRowIndexPath, at: scrollPosition, animated: animated)
    }
}

#Preview {
    MessageListView(ChatRoomViewModel(.placeholder))
        .ignoresSafeArea()
}
