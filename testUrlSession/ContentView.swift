//
//  ContentView.swift
//  testUrlSession
//
//  Created by Xiaofeng Feng on 2022/12/14.
//

import SwiftUI

enum AppState: String {
    case pending, downloaded, downloadFailed, moved, moveFailed;
}

class ViewModel: NSObject, ObservableObject, URLSessionDelegate, URLSessionDownloadDelegate {
    static public let shared = ViewModel()
    
    @Published
    var appState: AppState = .pending
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        NSLog("Error")
        self.appState = .downloadFailed
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        NSLog("downloaded to \(location.absoluteString)")
        self.appState = .downloaded
        
        do {
            let documentsURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            let savedURL = documentsURL.appendingPathComponent(location.lastPathComponent)
            try FileManager.default.moveItem(at: location, to: savedURL)
            NSLog("File is successfully moved.")
            self.appState = .moved
            
        } catch {
            NSLog("Failed to move the file: \(error)")
            self.appState = .moveFailed
        }
        
    }
    
}

struct ContentView: View {
    @ObservedObject var vm = ViewModel.shared
    
    var body: some View {
        Text(vm.appState.rawValue)
            .font(.system(size: 50))
            .onAppear() {
                let url = URL(string: "https://www.baidu.com/img/PCfb_5bf082d29588c07f842ccde3f97243ea.png")
                
                let config = URLSessionConfiguration.background(withIdentifier: "ABC")
                URLSession(configuration: config, delegate: vm, delegateQueue: OperationQueue.main).downloadTask(with: url!)
                    .resume()
            }
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
