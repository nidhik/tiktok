//
//  VideoCompositionWriter.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/13/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCompositionWriter: NSObject {
    
    func merge(arrayVideos:[AVAsset]) -> AVMutableComposition {

      let mainComposition = AVMutableComposition()
      let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
      compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)

  //    let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        var insertTime = CMTime.zero

      for videoAsset in arrayVideos {
        try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
    //    try! soundtrackTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)

        insertTime = CMTimeAdd(insertTime, videoAsset.duration)
      }
        return mainComposition
    }

    func mergeAudioVideo(_ documentsDirectory: URL, filename: String, clips: [String], completion: @escaping (Bool, URL?) -> Void) {
        
        
        var assets: [AVAsset] = []
        var totalDuration = CMTime.zero
    
        for clip in clips {
            let videoFile = documentsDirectory.appendingPathComponent(clip)
            let asset = AVURLAsset(url: videoFile)
            assets.append(asset)
            totalDuration = CMTimeAdd(totalDuration, asset.duration)
        }

        // 3 - Audio track
        let mixComposition = merge(arrayVideos: assets)
        guard let audioUrl = Bundle.main.url(forResource: "Body_Language", withExtension: "mp3") else { return }
        let loadedAudioAsset = AVURLAsset(url: audioUrl)
          let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)
          do {
            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                            duration: totalDuration),
                                            of: loadedAudioAsset.tracks(withMediaType: AVMediaType.audio)[0] ,
                                            at: CMTime.zero)
          } catch {
            print("Failed to load Audio track")
          }
        

        // 4 - Get path
        
        let url = documentsDirectory.appendingPathComponent("out_\(filename)")

        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition,
                                                  presetName: AVAssetExportPresetHighestQuality) else {
          return
        }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true

        // 6 - Perform the Export
        exporter.exportAsynchronously() {
          DispatchQueue.main.async {
            if exporter.status == .completed {
                completion(true, exporter.outputURL)
            } else {
                completion(false, nil);
            }
            
          }
        }

    }

}
