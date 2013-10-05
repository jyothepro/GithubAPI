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
#import <ISDiskCache.h>

NSString *const DiskCacheConstantOrg = @"ORG";
NSString *const DiskCacheConstantUser = @"User";

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
		[ISDiskCache sharedCache].limitOfSize = 1024 * 1024;
    });
	
    return sharedInstance;
}


-(void) getAllMembersFromServer:(void (^)(NSDictionary *data))callback
		errorCallback:(void (^)(NSError *error))errorCallback {
	//[NSException raise:@"Cant call server" format:@"sever is locked"];
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

-(void) getAllMembers:(void (^)(NSDictionary *data))callback
		errorCallback:(void (^)(NSError *error))errorCallback {
	NSDictionary *data = [[ISDiskCache sharedCache] objectForKey:DiskCacheConstantOrg];
	if (data) {
		NSNumber *ttl = [data objectForKey:@"ttl"];
		NSTimeInterval interval = [ttl doubleValue];
		
		if (interval <= [[NSDate date] timeIntervalSince1970]) {
			callback([data objectForKey:@"response"]);
			return;
		}
	}
	
	[[GithubAPIService sharedInstance] getAllMembersFromServer:^(NSDictionary *data) {
		NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
		
		NSDictionary *respData = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithDouble:currentTime], @"ttl",
								  data, @"response",
								  nil
								  ];
		[[ISDiskCache sharedCache] setObject:respData forKey:DiskCacheConstantOrg];
		callback(data);
	}
												 errorCallback:^(NSError *error) {
													 errorCallback(error);
												 }
	 ];
}

-(NSDictionary *) getMember:(NSString *)userID {
	NSDictionary *data = [[ISDiskCache sharedCache] objectForKey:DiskCacheConstantOrg];
	
	if (data) {
		NSNumber *ttl = [data objectForKey:@"ttl"];
		NSTimeInterval interval = [ttl doubleValue];
		
		if (interval <= [[NSDate date] timeIntervalSince1970]) {
			
			return [[data objectForKey:@"response"] objectForKey:userID];
		}
	}
	return false;
}

-(void) getUserProfileFromServer:(NSString *)userID
		  withCallback:(void (^)(NSDictionary *data))callback
		 errorCallback:(void (^)(NSError *error))errorCallback {
	NSDictionary *user = [[GithubAPIService sharedInstance] getMember:userID];
	NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:10];
	
	NSString *profileUrl = [NSString stringWithFormat:@"%@%@", @"https://api.github.com/users/", [user objectForKey:@"login"]];
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	[manager GET:profileUrl
	  parameters:nil
		 success:^(AFHTTPRequestOperation *operation, id responseObject) {
			 [userProfile setObject:[responseObject objectForKey:@"name"] forKey:@"name"];
			 [userProfile setObject:[responseObject objectForKey:@"company"] forKey:@"company"];
			 [userProfile setObject:[responseObject objectForKey:@"blog"] forKey:@"blog"];
			 [userProfile setObject:[responseObject objectForKey:@"location"] forKey:@"location"];
			 [userProfile setObject:[responseObject objectForKey:@"bio"] forKey:@"bio"];
			 [userProfile setObject:[[GithubAPIService sharedInstance] getGravatarUrl:[responseObject objectForKey:@"gravatar_id"] andSize:@"200"] forKey:@"picUrl"];
			 [userProfile setObject:[responseObject objectForKey:@"public_repos"] forKey:@"public_repos"];
			 [userProfile setObject:[responseObject objectForKey:@"followers"] forKey:@"followers"];
			 [userProfile setObject:[responseObject objectForKey:@"following"] forKey:@"following"];
			 
			 //NSLog(@"API Data: %@", userProfile);
			 if (callback) {
				 callback(userProfile);
			 }
		 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			 //NSLog(@"Error: %@", error);
			 if (errorCallback) {
				 errorCallback(error);
			 }
		 }];
	
	
}

-(void) getUserProfile:(NSString *)userID
		  withCallback:(void (^)(NSDictionary *data))callback
		 errorCallback:(void (^)(NSError *error))errorCallback {
	NSDictionary *data = [[ISDiskCache sharedCache] objectForKey:[NSString stringWithFormat:@"%@%@",DiskCacheConstantUser,userID]];
	
	if (data) {
		NSNumber *ttl = [data objectForKey:@"ttl"];
		NSTimeInterval interval = [ttl doubleValue];
		
		if (interval <= [[NSDate date] timeIntervalSince1970]) {
			callback([data objectForKey:@"response"]);
			return;
		}
	}
	
	[[GithubAPIService sharedInstance] getUserProfileFromServer:userID
												   withCallback:^(NSDictionary *data) {
													   NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
													   NSDictionary *respData = [NSDictionary dictionaryWithObjectsAndKeys:
																				 [NSNumber numberWithDouble:currentTime], @"ttl",
																				 data, @"response",
																				 nil
																				 ];
													   [[ISDiskCache sharedCache] setObject:respData forKey:[NSString stringWithFormat:@"%@%@",DiskCacheConstantUser,userID]];
													   if (callback) {
														   callback(data);
													   }
													   
												   }
												 errorCallback:^(NSError *error) {
													 if (errorCallback) {
															errorCallback(error);
													 }
												 }
	 ];
}

-(void) getProfile:(void (^)(NSDictionary *data))callback
	 errorCallback:(void (^)(NSError *error))errorCallback {
	
}

-(void) getFollowers:(NSString *)url
		withCallback:(void (^)(NSDictionary *data))callback
	   errorCallback:(void (^)(NSError *error))errorCallback {
	
}

-(void) getFollowing:(NSString *)url
		withCallback:(void (^)(NSDictionary *data))callback
	   errorCallback:(void (^)(NSError *error))errorCallback {
	
}

-(void) getOrganisations:(NSString *)url
			withCallback:(void (^)(NSDictionary *data))callback
		   errorCallback:(void (^)(NSError *error))errorCallback {
	
}

-(NSString *) getGravatarUrl:(NSString *)gravtarId andSize:(NSString*)size {
	return [NSString stringWithFormat:@"%@%@%@%@",
			@"http://www.gravatar.com/avatar/",
			gravtarId,
			@"?s=",
			size];
}

@end
