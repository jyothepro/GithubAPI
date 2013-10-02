//
//  GithubAPIService.m
//  GithubAPI
//
//  Created by Jyothidhar Pulakunta on 10/1/13.
//  Copyright (c) 2013 Jyothidhar Pulakunta. All rights reserved.
//

#import "GithubAPIService.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <JSONKit.h>

@interface GithubAPIService ()
@property(nonatomic, retain) NSDictionary *userData;
@end

@implementation GithubAPIService
@synthesize userData = _userData;

+(GithubAPIService *)sharedInstance {
    static GithubAPIService *sharedInstance = nil;
	static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	
    return sharedInstance;
}

-(void) getAllMembers:(void (^)(NSDictionary *data))callback
		errorCallback:(void (^)(NSError *error))errorCallback {
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	[manager GET:@"https://api.github.com/orgs/shopsavvy/public_members"
	  parameters:nil
		 success:^(AFHTTPRequestOperation *operation, id responseObject) {
			 NSMutableDictionary *userData = [NSMutableDictionary dictionaryWithCapacity:[responseObject count]];
			 for (int i=0; i<[responseObject count]; i++) {
				 NSDictionary *temp = [responseObject objectAtIndex:i];
				 [userData setObject:temp forKey:[temp objectForKey:@"id"]];
			 }
			 _userData = [NSMutableDictionary dictionaryWithDictionary:userData];
		
			 //NSLog(@"API Data: %@", _userData);
			 if (callback) {
				 callback(userData);
			 }
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		//NSLog(@"Error: %@", error);
		if (errorCallback) {
			errorCallback(error);
		}
	}];
}

-(void) getMember:(NSString *) id
andWithCallback:(void (^)(id data))callback
errorCallback:(void (^)(NSError *error))errorCallback {
	if (!_userData) {
		[self getAllMembers:^(NSDictionary *data) {
			if (callback) {
				callback([data objectForKey:id]);
			}
		}
			  errorCallback:^(NSError *error){
				  if (errorCallback) {
					  errorCallback(error);
				  }
		}];
	}
	
	callback([_userData objectForKey:id]);
}
@end
