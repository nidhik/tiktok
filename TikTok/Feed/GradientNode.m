/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "GradientNode.h"

@implementation GradientNode

+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters
     isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing {
  CGContextRef myContext = UIGraphicsGetCurrentContext();
  CGContextSaveGState(myContext);
  CGContextClipToRect(myContext, bounds);

  NSInteger componentCount = 2;

  CGFloat zero = 0.0;
  CGFloat one = 1.0;
  CGFloat locations[2] = {zero, one};
  CGFloat components[8] = {zero, zero, zero, one, zero, zero, zero, zero};

  CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorSpace, components, locations, componentCount);

  CGPoint myStartPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds));
  CGPoint myEndPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

  CGContextDrawLinearGradient(myContext, myGradient, myStartPoint, myEndPoint, kCGGradientDrawsAfterEndLocation);

  CGContextRestoreGState(myContext);
}

@end
