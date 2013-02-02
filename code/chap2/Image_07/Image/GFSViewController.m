//
//  GFSViewController.m
//  Image
//
//  Created by Bill Dudney on 1/4/13.
//  Copyright (c) 2013 Gala Factory Software LLC. All rights reserved.
//

#import "GFSViewController.h"
#import <ImageIO/ImageIO.h>
#import "GFSPropertiesViewController.h"

@interface GFSViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *propertiesGR;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *animateGR;

@end

static NSString *const kImageName = @"wwdc.png";

@implementation GFSViewController

#pragma mark - View Controller methods

- (void)viewDidLoad {
  [self.view layoutIfNeeded];
  self.imageView.image = [self thumbnailImage];
  [self.animateGR requireGestureRecognizerToFail:self.propertiesGR];
}

- (IBAction)animate:(UITapGestureRecognizer *)gr {
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([[segue identifier] isEqualToString:@"ShowPropertiesSegue"]) {
    UIViewController *vc = [segue destinationViewController];
    if([vc isKindOfClass:[GFSPropertiesViewController class]]) {
      [(GFSPropertiesViewController *)vc setProperties:[self propertiesForImage]];
    } else {
      UINavigationController *nav = (UINavigationController *)vc;
      GFSPropertiesViewController *propVC =
            (GFSPropertiesViewController *)[nav topViewController];
      [propVC setProperties:[self propertiesForImage]];
    }
  }
}

#pragma mark - Image Loader Methods

- (UIImage *)thumbnailImage {
  UIImage *image = nil;
  
  BOOL cachedFileExists = [self cachedImageFileExists];
  if(cachedFileExists) {
    NSURL *imgURL = [self cachedImageFileURL];
    image = [UIImage imageWithContentsOfFile:[imgURL path]];
  } else {
    image = [self cacheThumbnailImage];
  }
  
  return image;
}

- (BOOL)cachedImageFileExists {
  NSFileManager *manager = [NSFileManager defaultManager];
  NSURL *imgURL = [self cachedImageFileURL];
  NSError *error = nil;
  NSDictionary *attributes = [manager attributesOfFileSystemForPath:[imgURL path]
                                                              error:&error];
  return (nil != attributes);
}

- (NSURL *)cachedImageFileURL {
  NSFileManager *manager = [NSFileManager defaultManager];
  NSURL *docDir = [[manager URLsForDirectory:NSDocumentDirectory
                                   inDomains:NSUserDomainMask] lastObject];
  NSURL *imgURL = [docDir URLByAppendingPathComponent:kImageName];
  return imgURL;
}

- (UIImage *)cacheThumbnailImage {
  CGFloat maxDim = [self maxDim];
  NSURL *url = [[NSBundle mainBundle] URLForResource:[kImageName stringByDeletingPathExtension]
                                       withExtension:[kImageName pathExtension]];
  CFURLRef sourceURL = (__bridge CFURLRef)url;
  CGImageSourceRef imgSrc = CGImageSourceCreateWithURL(sourceURL, NULL);
  
  NSNumber *max = [NSNumber numberWithFloat:maxDim];
  NSDictionary *options = @{
  (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
  (__bridge NSNumber *)kCGImageSourceThumbnailMaxPixelSize : max
  };
  CFDictionaryRef cfOptions = (__bridge CFDictionaryRef)options;
  CGImageRef img = CGImageSourceCreateThumbnailAtIndex(imgSrc, 0, cfOptions);

  CFStringRef type = CGImageSourceGetType(imgSrc);
  NSURL *imgURL = [self cachedImageFileURL];
  CFURLRef destURL = (__bridge CFURLRef)imgURL;
  CGImageDestinationRef imgDest = CGImageDestinationCreateWithURL(destURL,
                                                                  type,
                                                                  1,
                                                                  NULL);
  CGImageDestinationAddImage(imgDest, img, NULL);
  CGImageDestinationFinalize(imgDest);
  
  UIImage *image = [UIImage imageWithCGImage:img];
  CFRelease(imgSrc);
  CGImageRelease(img);
  CFRelease(imgDest);
  
  return image;
}

- (CGFloat)maxDim {
  UIImage *image = [UIImage imageNamed:kImageName];
  CGFloat imageAR = image.size.width / image.size.height;
  image = nil;
  
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

- (NSDictionary *)propertiesForImage {
  NSBundle *main = [NSBundle mainBundle];
  NSURL *imgURL = [main URLForResource:[kImageName stringByDeletingPathExtension]
                         withExtension:[kImageName pathExtension]];
  CFURLRef url = (__bridge CFURLRef)imgURL;
  CGImageSourceRef imgSrc = CGImageSourceCreateWithURL(url, NULL);
  CFDictionaryRef fileProperties = CGImageSourceCopyProperties(imgSrc, NULL);
  CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imgSrc,
                                                                       0,
                                                                       NULL);
  
  NSMutableDictionary *properties =
    [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)fileProperties];
  [properties addEntriesFromDictionary:(__bridge NSDictionary *)imageProperties];
  
  CFRelease(imgSrc);
  CFRelease(fileProperties);
  CFRelease(imageProperties);
  
  return [properties copy];
}

@end
