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
        
        let firstVideoFile = documentsDirectory.appendingPathComponent(clips[0])
        let secondVideoFile = documentsDirectory.appendingPathComponent(clips[1])
        let firstAsset = AVURLAsset(url: firstVideoFile)
        let secondAsset = AVURLAsset(url: secondVideoFile)

//        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
//        let mixComposition = AVMutableComposition()
//
//        // 2 - Create two video tracks
//        guard
//          let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
//                                                          preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//          else {
//            return
//        }
//        do {
//            let videoTimeRange = CMTimeRange(start: .zero, duration: firstAsset.duration)
//            try firstTrack.insertTimeRange(videoTimeRange,
//                                         of: firstAsset.tracks(withMediaType: AVMediaType.video)[0],
//                                         at: CMTime.zero)
//            let rotationTransform = CGAffineTransform(rotationAngle: .pi / 2);
//            firstTrack.preferredTransform = rotationTransform;
//        } catch {
//          print("Failed to load first track")
//          return
//        }
//
//        guard
//          let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
//                                                           preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//          else {
//            return
//        }
//        do {
//            try secondTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: secondAsset.duration),
//                                          of: secondAsset.tracks(withMediaType: AVMediaType.video)[0],
//                                          at: firstAsset.duration)
//            let rotationTransform = CGAffineTransform(rotationAngle: .pi / 2);
//            secondTrack.preferredTransform = rotationTransform;
//        } catch {
//          print("Failed to load second track")
//          return
//        }

        // 3 - Audio track
        let mixComposition = merge(arrayVideos: [firstAsset, secondAsset])
        guard let audioUrl = Bundle.main.url(forResource: "Body_Language", withExtension: "mp3") else { return }
        let loadedAudioAsset = AVURLAsset(url: audioUrl)
          let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)
          do {
            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
                                                            duration: CMTimeAdd(firstAsset.duration,
                                                                      secondAsset.duration)),
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
