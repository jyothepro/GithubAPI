//
//  GithubUserViewController.m
//  GithubAPI
//
//  Created by Jyothidhar Pulakunta on 10/2/13.
//  Copyright (c) 2013 Jyothidhar Pulakunta. All rights reserved.
//

#import "GithubUserViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GithubAPIService.h"

@interface GithubUserViewController ()
@property (nonatomic, retain) NSDictionary *user;
@property (nonatomic, retain) NSDictionary *profile;
@end

@implementation GithubUserViewController
@synthesize user = _user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithUser: (NSDictionary*)user {
	self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		_user = user;
		NSLog(@"MY User %@", _user);
    }
    return self;
}

-(NSString *) validateText:(NSString *)text {
	return (text == (id)[NSNull null] || text.length == 0 ) ? @"" : text;
}

- (void) updateView:(NSDictionary *)data {
	NSLog(@"DATA: %@", data);
	//User Image
	UIImageView *addImage = [[UIImageView alloc] init];
	[self.view addSubview:addImage];
	[addImage setImageWithURL:[NSURL URLWithString:[data objectForKey:@"picUrl"]]
			 placeholderImage:[UIImage imageNamed:@"default.avatar.png"]
					  options:SDWebImageCacheMemoryOnly
	 ];
	[addImage setFrame:CGRectMake(10, 75, 100, 100)];
	
	//Name
	UILabel *name = [[UILabel alloc] init];
	[self.view addSubview:name];
	name.text = [self validateText:[data objectForKey:@"name"]];
	[name setFrame:CGRectMake(125, 80, 150, 20)];
	
	//Company
	UILabel *company = [[UILabel alloc] init];
	[self.view addSubview:company];
	company.text = [self validateText:[data objectForKey:@"company"]];
	[company setFrame:CGRectMake(125, 110, 150, 20)];
	
	//Location
	UILabel *location = [[UILabel alloc] init];
	[self.view addSubview:location];
	location.text = [self validateText:[data objectForKey:@"location"]];
	[location setFrame:CGRectMake(125, 140, 150, 20)];

	//Followers
	UILabel *followers = [[UILabel alloc] init];
	[self.view addSubview:followers];
	followers.text = [NSString stringWithFormat:@"%@: %@", @"Followers", [data objectForKey:@"followers"]];
	[followers setFrame:CGRectMake(15, 190, self.view.frame.size.width - 15, 20)];
	
	//Following
	UILabel *following = [[UILabel alloc] init];
	[self.view addSubview:following];
	following.text = [NSString stringWithFormat:@"%@: %@", @"Following", [data objectForKey:@"following"]];
	[following setFrame:CGRectMake(15, 220, self.view.frame.size.width - 15, 20)];
	
	//Blog
	UILabel *blog = [[UILabel alloc] init];
	[self.view addSubview:blog];
	blog.text = [NSString stringWithFormat:@"%@: %@", @"Blog", [self validateText:[data objectForKey:@"blog"]]];
	blog.adjustsFontSizeToFitWidth = YES;
	[blog setFrame:CGRectMake(15, 250, self.view.frame.size.width - 15, 20)];
	
	//Bio
	UILabel *bio = [[UILabel alloc] init];
	[self.view addSubview:bio];
	NSString *bioTxt = [data objectForKey:@"bio"];
	bio.text = [NSString stringWithFormat:@"%@: %@", @"Bio", [self validateText:bioTxt]];
	bio.numberOfLines = 2;
	bio.adjustsFontSizeToFitWidth = YES;
	[bio setFrame:CGRectMake(15, 280, self.view.frame.size.width - 15, 40)];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
	[self updateView:_profile];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title = [_user objectForKey:@"login"];
	self.view.backgroundColor = [UIColor whiteColor];
	
	[[GithubAPIService sharedInstance] getUserProfile:[_user objectForKey:@"id"]
										 withCallback:^(NSDictionary *data) {
											 _profile = data;
											 [self updateView:data];
										 }
										errorCallback:^(NSError *error) {
											UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
																	   message: @"Cannot connect to server try later"
																	  delegate:nil
															 cancelButtonTitle:nil
															 otherButtonTitles:nil];
											[alert show];
										}
	 ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
