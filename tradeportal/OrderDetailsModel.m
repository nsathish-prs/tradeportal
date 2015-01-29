//
//  OrderDetailsModel.m
//  TradePortal
//
//  Created by Nagarajan Sathish on 6/1/15.
//
//

#import "OrderDetailsModel.h"

@implementation OrderDetailsModel

@synthesize rec_Id,statusMessage,updated_By;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init])){
        self.rec_Id = [aDecoder decodeObjectForKey:@"rec_Id"];
        self.statusMessage = [aDecoder decodeObjectForKey:@"statusMessage"];
        self.updated_By = [aDecoder decodeObjectForKey:@"updated_By"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.rec_Id forKey:@"rec_Id"];
    [aCoder encodeObject:self.statusMessage forKey:@"statusMessage"];
    [aCoder encodeObject:self.updated_By forKey:@"updated_By"];
    
    
}


@end
