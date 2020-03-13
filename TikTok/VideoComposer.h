//
//  VideoComposer.h
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/12/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoComposer : UIView

-(void)mergeAudioVideo: (NSURL *) _documentsDirectory;
@end

NS_ASSUME_NONNULL_END
