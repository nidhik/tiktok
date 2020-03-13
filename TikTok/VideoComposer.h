//
//  VideoComposer.h
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/12/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^VideoComposeCompletion)(BOOL);

@interface VideoComposer : UIView

-(void)mergeAudioVideo: (NSURL *) _documentsDirectory filename: (NSString *) filename completion:(VideoComposeCompletion)completion;
@end

NS_ASSUME_NONNULL_END
