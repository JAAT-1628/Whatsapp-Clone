//
//  AudioRecordingService.swift
//  Whatsapp
//
//  Created by Riptik Jhajhria on 21/02/25.
//

import Foundation
import AVFoundation
import Combine

final class AudioRecordingService {
    private var audioRecorder: AVAudioRecorder?
    @Published private(set) var isRecording = false
    @Published private(set) var elaspedTime: TimeInterval = 0
    private var startTime: Date?
    private var timer: AnyCancellable?
    
    deinit {
        tearDown()
    }
    
    func startRecording() {
        //setingup AudioSession
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
        } catch {
            print("AudioRecordingService: Failed to setup AVAudioSession")
        }
        
        //storing the audio message URL
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = Date().toString(format: "dd-MM-yy 'at' HH:mm:ss") + ".m4a"
        let audioFileURL = documentPath.appendingPathComponent(audioFileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        generateHapticSound()
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
            startTime = Date()
            startTimer()
        } catch {
            print("AudioRecordingService: Failed to setup AVAudioRecorder")
        }
    }
    
    func stopRecording(completion: ((_ audioURL: URL?, _ audioDuration: TimeInterval) -> Void)? = nil) {
        guard isRecording else { return }
        let audioDuration = elaspedTime
        audioRecorder?.stop()
        isRecording = false
        timer?.cancel()
        elaspedTime = 0
        generateHapticSound()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            guard let audioURL = audioRecorder?.url else { return }
            completion?(audioURL, audioDuration)
        } catch {
            print("AudioRecordingService: Failed to teardown AVAudioSession")
        }
    }
    
    func tearDown() {
        if isRecording { stopRecording() }
        let fileManager = FileManager.default
        let folder = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderContent = try! fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        deleteRecordings(folderContent)
    }
    
    private func deleteRecordings(_ urls: [URL]) {
        for url in urls {
            deleteRecording(at: url)
        }
    }
    
    func deleteRecording(at fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("AudioRecordingService: Failed to delete audio File")
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let startTime = self?.startTime else { return }
                self?.elaspedTime = Date().timeIntervalSince(startTime)
            }
    }
    
    private func generateHapticSound() {
        let systemSoundID: SystemSoundID = 1118
        AudioServicesPlaySystemSound(systemSoundID)
        Haptic.impact(.medium)
    }
}
