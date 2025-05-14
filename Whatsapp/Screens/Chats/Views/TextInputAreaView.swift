//
//  TextInputAreaView.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 13/02/25.
//

import SwiftUI

struct TextInputAreaView: View {
    @Binding var textMessage: String
    @Binding var isRecording: Bool
    @Binding var elapsedTime: TimeInterval
    @State private var showPlusButtonActions = false
    @State private var pulsing = false
    var mediaSendButton: Bool
    let actionHandler:(_ action: UserAction) -> ()
    
    var body: some View {
        HStack {
            if isRecording {
                audioSessionView()
                Image(systemName: "square.fill")
                    .resizable()
                    .foregroundStyle(.white)
                    .padding(8)
                    .frame(width: 30, height: 30)
                    .background(.green)
                    .clipShape(Circle())
                    .onTapGesture {
                        actionHandler(.recordAudio)
                        isRecording.toggle()
                    }
            } else {
                HStack {
                    leadingPlusButton()
                    messageTextField()
                }
                if textMessage.isEmptyOrWhiteSpace && mediaSendButton {
                    HStack(spacing: 12) {
                        rsButton()
                        cameraButton()
                        micButton()
                    }
                    .font(.title3)
                } else {
                    sendButton()
                }
            }
        }
        .animation(.easeInOut, value: isRecording)
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
        .animation(.spring, value: !textMessage.isEmpty)
        .onChange(of: isRecording, { oldValue, newValue in
            if newValue {
                withAnimation(.easeIn(duration: 1.3).repeatForever()) {
                    pulsing.toggle()
                }
            } else {
                pulsing = false
            }
        })
        .safeAreaInset(edge: .bottom) {
            if showPlusButtonActions {
                withAnimation(.spring) {
                    plusButtonAction()
                }
            }
        }
    }
    
    private func audioSessionView() -> some View {
        HStack(spacing: 14) {
            Image(systemName: "mic")
                .imageScale(.large)
                .foregroundStyle(.red)
                .scaleEffect(pulsing == true ? 1.2 : 0.6)
            
            Text(elapsedTime.formatElapsedTime)
                .font(.subheadline)
                .foregroundStyle(.gray)
            Spacer()
            
            Text("Recording Audio")
        }
        .padding(.horizontal, 6)
        .padding(5)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.gray.opacity(0.3)))
    }
    
    
    private func messageTextField() -> some View {
        TextField(" Chat", text: $textMessage, axis: .vertical)
            .font(.subheadline)
            .padding(.horizontal, 6)
            .padding(5)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.ultraThinMaterial))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.secondary, lineWidth: 1)
            }
    }
    
    private func leadingPlusButton() -> some View {
        Button {
            UIApplication.dismissKeyboard()
            showPlusButtonActions.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.title3)
                
        }
    }
    private func sendButton() -> some View {
        Button {
            actionHandler(.sendMessage)
        } label: {
            Image(systemName: "paperplane.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.green)
        }

    }
    
    private func plusButtonAction() -> some View {
        VStack(spacing: 30) {
            HStack(spacing: 30) {
                icon("photo.fill.on.rectangle.fill", foregroundStyle: .blue)
                    .onTapGesture {
                        actionHandler(.presentPhotoPicker)
                    }
                icon("camera.fill", foregroundStyle: .red)
                icon("location.fill", foregroundStyle: .green)
                icon("person.crop.circle", foregroundStyle: .orange)
            }
            HStack(spacing: 30) {
                icon("doc.fill", foregroundStyle: .blue)
                icon("chart.bar.fill", foregroundStyle: .yellow)
                icon("indianrupeesign.circle.fill", foregroundStyle: .green)
                icon("photo.badge.plus", foregroundStyle: .blue)
            }
        }
        .padding(20)
    }
    
    private func icon(_ iconName: String, foregroundStyle: Color) -> some View {
        Image(systemName: iconName)
            .imageScale(.large)
            .padding(14)
            .background(Color(.systemGray5))
            .clipShape(Circle())
            .foregroundStyle(foregroundStyle)
    }
    
    private func rsButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "indianrupeesign.circle")
        }
    }
    
    private func cameraButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera")
        }
    }
    
    private func micButton() -> some View {
        Button {
            actionHandler(.recordAudio)
            isRecording = true
        } label: {
            Image(systemName: "mic")
        }
    }
}

extension TextInputAreaView {
    enum UserAction {
        case presentPhotoPicker
        case sendMessage
        case recordAudio
    }
}

#Preview {
    TextInputAreaView(textMessage: .constant(""), isRecording: .constant(false), elapsedTime: .constant(0), mediaSendButton: false) { _ in
        
    }
}
