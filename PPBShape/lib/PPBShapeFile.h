//
//  PPBShapeFile.h
//  PPBShape
//
//  Created by showtekwh on 15/5/19.
//
//

#import <Foundation/Foundation.h>

@interface PPBShapeFile : NSObject
/// shp 的格式
@property (nonatomic, readonly) int shapeType;

/// shape 的名字
@property (nonatomic,copy, readonly) NSString *shapeName;

/// 记录数量
@property (nonatomic, readonly) int shapeCount;

/// 文件路径
@property (nonatomic,readonly,copy) NSString *shapePath;

/// 是打开已有的文件还是 还是 新创建一个
@property (nonatomic,readonly,assign) BOOL isCreate;

/*!
 * 以只读方式 打开一个.shp 文件
 *
 *  @param path 文件路径
 *
 *  @return 初始化 STShapeFile 打开失败返回nil
 */
+ (instancetype)openShapeFileWithPath:(NSString *)path;


/*!
 *  创建一个.shp 文件  文件不存在 创建文件，如果存在创建文件覆盖源文件
 *
 *  @param path     文件路径
 *  @param nSHPType 创建文件类型 写只支持 三种类型 （SHPT_POINT	1  SHPT_ARC	3  SHPT_POLYGON	5） 具体类型参考 shapefil.h 定义
 *
 *  @return 初始化 STShapeFile 创建失败返回nil
 */

+ (instancetype)createShapeFileWithPath:(NSString *)path  Type :(int)nSHPType;

/*!
 *  根据索引获取一条记录
 *
 *  @param index 要获取记录的索引
 *
 *  @return 返回 STShapePoint 对象数组
 */
- (NSArray *)coordinatesForIndex:(NSUInteger)index;


#pragma mark -只有通过 createDatabaseWithPath 创建的文件才能 调用此接口
/*!
 *  添加一条记录 只有在 createShapeFileWithPath：方式创建的对象才能 添加 否则 返回no
 *
 *  @param point 要添加的 STShapePoint数组
 *
 *  @return 成功返回yes 失败返回 no
 */
- (BOOL)addShapeObject:(NSArray*)point;

@end
