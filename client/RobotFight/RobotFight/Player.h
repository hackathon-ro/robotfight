//
//  Player.h
//  RobotFight
//
//  Created by George Jingoiu on 10/28/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Player : NSObject

@property (nonatomic , retain) NSString *name;
@property (nonatomic , readwrite) int score;
@property (nonatomic , readwrite) int totalGames;
@property (nonatomic , readwrite) int wins;
@property (nonatomic , readwrite) int hp;
@property (nonatomic , readwrite) CLLocationCoordinate2D coordinates;

@end
