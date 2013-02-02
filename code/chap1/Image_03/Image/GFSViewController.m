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

//LISTING:tapped
- (IBAction)tapped:(UITapGestureRecognizer *)gr {
  [UIView animateWithDuration:3.0 animations:^{
    self.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
  }
                   completion:^(BOOL finished) {
                     [UIView animateWithDuration:3.0
                                      animations:^{
                                        self.imageView.transform = CGAffineTransformIdentity;
                                      }];
                   }];
}
//LISTING:tapped

@end
