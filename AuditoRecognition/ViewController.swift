//
//  ViewController.swift
//  AuditoRecognition
//
//  Created by Rafael Oliveira on 23/02/23.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Text here"
        return label
    }()
    
    lazy var start: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start", for: .normal)
        button.configuration = .filled()
        button.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let audioEngine = AVAudioEngine()
    let speechReconizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    var isStart: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(start)
        view.addSubview(label)
        
        
        let constraints = [
            start.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            start.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            label.topAnchor.constraint(equalToSystemSpacingBelow: start.bottomAnchor, multiplier: 2),
            label.centerXAnchor.constraint(equalTo: start.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        requestPermission()
    }

    
    @objc func startRecording() {
        
        isStart = !isStart
        
        if isStart {
            startSpeechRecognization()
        } else {
            cancelSpeechRecongnization()
        }
        
    }
    
    func startSpeechRecognization() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Error start audio")
        }

        
        task = speechReconizer?.recognitionTask(with: request, resultHandler: { response, error in
            guard let response = response else {
                if error != nil {
                    print("Something whent wrote")
                }
                return
            }
            
            let message = response.bestTranscription.formattedString
            self.label.text = message
        })
    }
    
    func cancelSpeechRecongnization() {
        task.finish()
        task.cancel()
        task = nil
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { authState in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    print("Accepted")
                    self.start.isEnabled = true
                } else if authState == .denied {
                    print("Rejected")
                }
            }
        }
    }
}

