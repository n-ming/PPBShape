//
//  PPBShapePoint.h
//  PPBShape
//
//  Created by showtekwh on 15/5/19.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PPBShapePoint : NSObject
/// longitude
@property  (nonatomic,assign) double lon;
/// latitude
@property  (nonatomic,assign) double lat;
/// 经纬度值
@property  (nonatomic,assign,readonly) CLLocationCoordinate2D  coordinate;
/*!
 *  根据经纬度获取 STShapePoint对象
 *
 *  @param coordinate 经纬度
 *
 *  @return 返回 STShapePoint对象
 */
+ (instancetype)shapePointWithCoorinate:(CLLocationCoordinate2D)coordinate;

/*!
 *  根据经纬初始对象
 *
 *  @param coordinate 初始经纬度
 *
 *  @return 返回 STShapePoint对象
 */
- (instancetype)initWithCoorinate:(CLLocationCoordinate2D)coordinate;

@end
