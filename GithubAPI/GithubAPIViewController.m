//
//  GithubAPIViewController.m
//  GithubAPI
//
//  Created by Jyothidhar Pulakunta on 10/1/13.
//  Copyright (c) 2013 Jyothidhar Pulakunta. All rights reserved.
//

#import "GithubAPIViewController.h"
#import "GithubAPIService.h"

@interface GithubAPIViewController ()

@end

@implementation GithubAPIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[[GithubAPIService sharedInstance] getAllMembers:^(NSDictionary *data){
		NSLog(@"Data: %@", data);
	}
									   errorCallback:^(NSError *error) {
										   NSLog(@"Error: %@", error);
									   }];

	UILabel *myLable = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 50)];
	myLable.text = @"Testing";
	[self.view addSubview:myLable];
	
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
