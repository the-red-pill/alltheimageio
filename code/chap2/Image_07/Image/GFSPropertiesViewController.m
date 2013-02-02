//
//  GFSPropertiesViewController.m
//  Image
//
//  Created by Bill Dudney on 1/15/13.
//  Copyright (c) 2013 Gala Factory Software LLC. All rights reserved.
//

#import "GFSPropertiesViewController.h"

@interface GFSPropertiesViewController ()

@property(nonatomic, copy) NSArray *keys;

@end

@implementation GFSPropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)done:(id)sender {
  [self dismissViewControllerAnimated:YES completion:NULL];
}

// LISTING: table view stuffs
- (void)setProperties:(NSDictionary *)properties {
  _properties = [properties copy];
  self.keys = [_properties allKeys];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellID = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID
                                                          forIndexPath:indexPath];
  NSString *key = [self.keys objectAtIndex:indexPath.row];
  cell.textLabel.text = key;
  id value = [self.properties objectForKey:key];
  if(![value isKindOfClass:[NSDictionary class]]) {
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", value];
  } else {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = @"";
  }
  return cell;
}
// LISTING: table view stuffs

#pragma mark - Table view delegate

- (void)           tableView:(UITableView *)tableView
     didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *key = [self.keys objectAtIndex:indexPath.row];
  id value = [self.properties objectForKey:key];
  if([value isKindOfClass:[NSDictionary class]]) {
    GFSPropertiesViewController *detailViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"propertiesVC"];
    detailViewController.properties =
        [self.properties objectForKey:[self.keys objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailViewController
                                         animated:YES];
  }
}

@end
