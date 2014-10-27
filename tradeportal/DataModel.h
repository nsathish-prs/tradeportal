//
//  DataModel.h
//  tradeportal
//
//  Created by intern on 21/10/14.
//
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject{
    NSString *userID;
    NSString *sessionID;
    NSString *password;
}

@property(strong,nonatomic)NSString *userID;
@property(strong,nonatomic)NSString *sessionID;
@property(strong,nonatomic)NSString *password;

@end
