//
//  GFSViewController.m
//  Image
//
//  Created by Bill Dudney on 1/4/13.
//  Copyright (c) 2013 Gala Factory Software LLC. All rights reserved.
//

#import "GFSViewController.h"
#import <ImageIO/ImageIO.h>

@interface GFSViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GFSViewController

- (CGFloat)maxDim {
  UIImage *image = [UIImage imageNamed:@"bigimage.png"];
  CGFloat imageAR = image.size.width / image.size.height;
  image = nil; // free the image
  
  CGFloat maxDim = 0.0;
  CGRect imageViewBounds = self.imageView.bounds;
  CGFloat boundsAR = CGRectGetWidth(imageViewBounds) /
                     CGRectGetHeight(imageViewBounds);
  if((imageAR > 1.0 && boundsAR < 1.0) ||
     (imageAR < 1.0 && boundsAR > 1.0)) { // different orientations
    maxDim = MIN(CGRectGetWidth(imageViewBounds),
                 CGRectGetHeight(imageViewBounds));
  } else { // same orientation
    maxDim = MAX(CGRectGetWidth(imageViewBounds),
                 CGRectGetHeight(imageViewBounds));
  }
  return maxDim * [[UIScreen mainScreen] scale];
}

- (void)viewDidLoad {
  [self.view layoutIfNeeded];
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"bigimage"
                                       withExtension:@"jpg"];
  CFURLRef cfURL = (__bridge CFURLRef)url;
  CGImageSourceRef imgSrc = CGImageSourceCreateWithURL(cfURL, NULL);

  NSNumber *maxDim = [NSNumber numberWithFloat:[self maxDim]];
  NSDictionary *options = @{
  (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
  (__bridge NSNumber *)kCGImageSourceThumbnailMaxPixelSize : maxDim
  };
  CFDictionaryRef cfOptions = (__bridge CFDictionaryRef)options;
  CGImageRef img = CGImageSourceCreateThumbnailAtIndex(imgSrc, 0, cfOptions);
  self.imageView.image = [UIImage imageWithCGImage:img];

  CFRelease(imgSrc);
  CGImageRelease(img);
}

- (IBAction)tapped:(UITapGestureRecognizer *)gr {
  [UIView animateWithDuration:3.0
                   animations:^{
                     self.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
                   }
                   completion:^(BOOL finished) {
                     [UIView animateWithDuration:3.0
                                      animations:^{
                                        self.imageView.transform = CGAffineTransformIdentity;
                                      }];
                   }];
}

@end
