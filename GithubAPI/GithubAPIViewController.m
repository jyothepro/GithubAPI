//
//  GithubAPIViewController.m
//  GithubAPI
//
//  Created by Jyothidhar Pulakunta on 10/1/13.
//  Copyright (c) 2013 Jyothidhar Pulakunta. All rights reserved.
//

#import "GithubAPIViewController.h"
#import "GithubAPIService.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GithubUserViewController.h"
#import <MBProgressHUD.h>

@interface GithubAPIViewController ()
@property(nonatomic, retain) NSDictionary *githubUsers;
@end

@implementation GithubAPIViewController
@synthesize githubUsers = _githubUsers;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.title = @"ShopSavvy Users";
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[[GithubAPIService sharedInstance] getAllMembers:^(NSDictionary *data){
		dispatch_async(dispatch_get_main_queue(), ^{
			[MBProgressHUD hideHUDForView:self.view animated:YES];
		});
		
		NSLog(@"Data: %@", data);
		_githubUsers = data;
		[self.tableView reloadData];
	}
									   errorCallback:^(NSError *error) {
										   dispatch_async(dispatch_get_main_queue(), ^{
											   [MBProgressHUD hideHUDForView:self.view animated:YES];
										   });
										   
										   NSHTTPURLResponse *repsonse = [error.userInfo objectForKey:@"AFNetworkingOperationFailingURLResponseErrorKey"];
										   NSDictionary *respHeaders = [repsonse allHeaderFields];
										   NSString *failText = @"";
										   if ([respHeaders objectForKey:@"X-RateLimit-Remaining"]) {
											   NSString *rem = [respHeaders objectForKey:@"X-RateLimit-Remaining"];
											   if ([rem isEqualToString:@"0"]){
												   NSLog(@"Rate limit reached please try again later");
												   failText = @"Rate limit reached please try again later";
											   }
										   } else {
											   failText = @"Currently unable to fetch data try again later";
										   }
										   
										   UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
																							 message: failText
																							delegate:nil
																				   cancelButtonTitle:nil
																				   otherButtonTitles:nil];
										   [message show];
									   }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//count of section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//count number of rows
    return [_githubUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:MyIdentifier];
	}

	NSArray *keys = [_githubUsers allKeys];
	id aKey = [keys objectAtIndex:indexPath.row];
	
	NSString *loginName = [[_githubUsers objectForKey:aKey] objectForKey:@"login"];
	loginName = [loginName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[loginName substringToIndex:1] uppercaseString]];
	cell.textLabel.text = loginName;
	
	
	UIImageView *addImage = [[UIImageView alloc] init];
	[addImage setFrame:CGRectMake(3, 1, 40, 40)];
	[addImage setImageWithURL:[NSURL URLWithString:[[_githubUsers objectForKey:aKey] objectForKey:@"avatar_url"]]
			 placeholderImage:[UIImage imageNamed:@"default.avatar.png"]
					  options:SDWebImageCacheMemoryOnly
	 ];
	
	[cell.contentView addSubview:addImage];
	[cell setIndentationLevel:5];
	
	//cell.accessoryView = addImage;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSArray *keys = [_githubUsers allKeys];
	id aKey = [keys objectAtIndex:indexPath.row];
	
	GithubUserViewController *userVC = [[GithubUserViewController alloc] initWithUser:[_githubUsers objectForKey:aKey]];
	[self.navigationController pushViewController:userVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
