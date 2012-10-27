//
//  Weapon.m
//  RobotFight
//
//  Created by George Jingoiu on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Weapon.h"

@implementation Weapon

@synthesize ID , name , damage , radius , imgName;

//******************************************************************************************************************************
- (void) dealloc
{
    if(imgName)
        [imgName release];
    
    if(name)
        [name release];
    
    [super dealloc];
}
//******************************************************************************************************************************
@end
