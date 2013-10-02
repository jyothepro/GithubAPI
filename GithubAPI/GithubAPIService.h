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
-(void) getMember:(NSString *) id
andWithCallback:(void (^)(id data))callback
errorCallback:(void (^)(NSError *error))errorCallback;

@end
