//
//  GithubUserViewController.m
//  GithubAPI
//
//  Created by Jyothidhar Pulakunta on 10/2/13.
//  Copyright (c) 2013 Jyothidhar Pulakunta. All rights reserved.
//

#import "GithubUserViewController.h"

@interface GithubUserViewController ()
@property (nonatomic, retain) NSDictionary *user;
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

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title = [_user objectForKey:@"login"];
	self.view.backgroundColor = [UIColor whiteColor];
	
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
