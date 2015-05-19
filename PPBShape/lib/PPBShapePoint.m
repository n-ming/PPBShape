//
//  PPBShapePoint.m
//  PPBShape
//
//  Created by showtekwh on 15/5/19.
//
//

#import "PPBShapePoint.h"

@implementation PPBShapePoint
+ (instancetype)shapePointWithCoorinate:(CLLocationCoordinate2D)coordinate;
{
    PPBShapePoint *point = [[PPBShapePoint alloc] initWithCoorinate:coordinate];
    return point;
}
- (instancetype)initWithCoorinate:(CLLocationCoordinate2D)coordinate
{
    if (self == [super  init]) {
        
        self.lon = coordinate.longitude;
        self.lat = coordinate.latitude;
    }
    return self;
}
- (CLLocationCoordinate2D)coordinate
{
    return  CLLocationCoordinate2DMake(self.lat, self.lon);
}
- (NSString*)description
{
    
    return [NSString stringWithFormat:@"lon = %.4lf,lat = %.4lf",self.lon,self.lat];
}

@end
