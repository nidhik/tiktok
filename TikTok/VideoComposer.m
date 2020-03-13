//
//  VideoComposer.m
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/12/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

#import "VideoComposer.h"
#import <AVFoundation/AVFoundation.h>
@implementation VideoComposer

-(void)mergeAudioVideo: (NSURL *) _documentsDirectory {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *videoOutputPath = [bundle pathForResource:@"P1" ofType:@"mp4"];
    NSURL *outputFileURL = [_documentsDirectory URLByAppendingPathComponent:@"final_video.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path])
        [[NSFileManager defaultManager]removeItemAtPath:outputFileURL.path error:nil];
    
    NSString *filePath = [bundle pathForResource:@"shake_it_off" ofType:@"m4a"];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];

    NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:filePath];
    NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:videoOutputPath];

    CMTime nextClipStartTime = kCMTimeZero;

    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);

    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];

    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];

    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = outputFileURL;

    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         if (_assetExport.status == AVAssetExportSessionStatusCompleted) {

             NSLog(_assetExport.outputURL.absoluteString);
         }
         else {
            //Write Fail Code here
         }
     }
     ];

}

@end
