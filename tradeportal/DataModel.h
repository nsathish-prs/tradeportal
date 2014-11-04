//
//  DataModel.h
//  tradeportal
//
//  Created by Nagarajan Sathish on 21/10/14.
//
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject{
    NSString *userID;
    NSString *sessionID;
    NSString *password;
    UIViewController *fromView;
    UIViewController *toView;
}

# define iGREEN [UIColor colorWithRed:64.0f/255.0f green:177.0f/255.0f blue:64.0f/255.0f alpha:1.0f]
# define iRED [UIColor colorWithRed:255.0f/255.0f green:110.0f/255.0f blue:118.0f/255.0f alpha:1.0f]
# define iERROR [UIColor colorWithRed:200.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
# define iRELOAD [UIColor colorWithRed:179.0f/255.0f green:179.0f/255.0f blue:179.0f/255.0f alpha:1.0f]

@property(strong,nonatomic)NSString *userID;
@property(strong,nonatomic)NSString *sessionID;
@property(strong,nonatomic)NSString *password;
@property(strong,nonatomic)UIViewController *fromView;
@property(strong,nonatomic)UIViewController *toView;
@end
