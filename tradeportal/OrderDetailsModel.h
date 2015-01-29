//
//  OrderDetailsModel.h
//  TradePortal
//
//  Created by Nagarajan Sathish on 6/1/15.
//
//

#import <Foundation/Foundation.h>

@interface OrderDetailsModel : NSObject{
    NSString *recId;
    NSString *msg;
    NSString *updatedBy;

    
}
@property(nonatomic,strong)NSString *rec_Id;
@property(nonatomic,strong)NSString *statusMessage;
@property(nonatomic,strong)NSString *updated_By;


@end
