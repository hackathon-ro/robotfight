//
//  Weapon.h
//  RobotFight
//
//  Created by George Jingoiu on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weapon : NSObject
{
    int damage;
    int radius;
    int ID;
    NSString *name;
    NSString *imgName;
}

@property (nonatomic , readwrite) int damage;
@property (nonatomic , readwrite) int radius;
@property (nonatomic , readwrite) int ID;
@property (nonatomic , retain) NSString *name;
@property (nonatomic , retain) NSString *imgName;

@end
