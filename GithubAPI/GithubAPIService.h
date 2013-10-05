//
//  GithubAPIService.h
//  GithubAPI
//
//  Created by Jyothidhar Pulakunta on 10/1/13.
//  Copyright (c) 2013 Jyothidhar Pulakunta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GithubAPIService : NSObject

+(GithubAPIService *)sharedInstance;

-(void) getAllMembers:(void (^)(NSDictionary *data))callback
          errorCallback:(void (^)(NSError *error))errorCallback;

-(void) getFollowers:(NSString *)url
		withCallback:(void (^)(NSDictionary *data))callback
		errorCallback:(void (^)(NSError *error))errorCallback;

-(void) getFollowing:(NSString *)url
		withCallback:(void (^)(NSDictionary *data))callback
	   errorCallback:(void (^)(NSError *error))errorCallback;

-(void) getOrganisations:(NSString *)url
		withCallback:(void (^)(NSDictionary *data))callback
	   errorCallback:(void (^)(NSError *error))errorCallback;

-(void) getProfile:(void (^)(NSDictionary *data))callback
	 errorCallback:(void (^)(NSError *error))errorCallback;

-(NSString *) getGravatarUrl:(NSString *)gravtarId andSize:(NSString*)size;

-(void) getUserProfile:(NSString *)userID
		  withCallback:(void (^)(NSDictionary *data))callback
		 errorCallback:(void (^)(NSError *error))errorCallback;

//https://api.github.com/users/dlmitchell


@end
