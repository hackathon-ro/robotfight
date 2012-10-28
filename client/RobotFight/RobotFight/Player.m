//
//  Player.m
//  RobotFight
//
//  Created by George Jingoiu on 10/28/12.
//
//

#import "Player.h"

@implementation Player

@synthesize name , score , totalGames , wins , coordinates , hp , ID;

//******************************************************************************************************************************
- (id) init
{
    if((self = [super init]))
    {
        name        = nil;
        score       = 0;
        totalGames  = 0;
        wins        = 0;
        hp          = 0;
        ID          = 0;
    }
    return self;
}
//******************************************************************************************************************************
- (NSString *) description
{
    return [NSString stringWithFormat:@"ID:%d   Name:%@    Coordinates:%.4f x %.4f   hp:%d" , self.ID , self.name , self.coordinates.latitude , self.coordinates.longitude , self.hp];
}
//******************************************************************************************************************************
- (void) dealloc
{
    [name   release];
    [super  dealloc];
}
//******************************************************************************************************************************
@end
