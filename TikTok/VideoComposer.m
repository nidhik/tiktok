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

-(void)mergeAudioVideo: (NSURL *) _documentsDirectory filename: (NSString *) filename completion:(VideoComposeCompletion) completion{
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSURL *outputFileURL = [_documentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"out_%@", filename]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path])
        [[NSFileManager defaultManager]removeItemAtPath:outputFileURL.path error:nil];
    
    NSString *filePath = [bundle pathForResource:@"Body_Language" ofType:@"mp3"];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:filePath];
    NSURL *video_inputFileUrl = [_documentsDirectory URLByAppendingPathComponent:filename];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
       CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI_2);
    //    CGAffineTransform rotateTranslate = CGAffineTransformTranslate(rotationTransform,360,0);
        a_compositionVideoTrack.preferredTransform = rotationTransform;
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
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
        
        completion(_assetExport.status == AVAssetExportSessionStatusCompleted);
    }
     ];
    
}

@end
