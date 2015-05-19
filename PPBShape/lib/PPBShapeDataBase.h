//
//  PPBShapeDataBase.h
//  PPBShape
//
//  Created by showtekwh on 15/5/19.
//
//

#import <Foundation/Foundation.h>
#import "shapefil.h"

@interface PPBShapeDataBase : NSObject
/// 属性的数量
@property (nonatomic,assign ,readonly) NSUInteger fieldCount;

/// 所有属性
@property (nonatomic,strong ,readonly) NSArray *fields;

/// 记录总数
@property (nonatomic,assign ,readonly) int recordsCount;

/// 所有记录
@property (readonly) NSArray *records;

/// 文件路径
@property (nonatomic,readonly,copy) NSString *databasePath;

/// 是打开已有的文件还是 还是 新创建一个
@property (nonatomic,readonly,assign) BOOL isCreate;

/// 字符串属性的编码方式 field编码方式  默认 NSUTF8StringEncoding
@property (nonatomic,assign) NSStringEncoding stringEncoding;

/*!
 * 以只读方式 打开一个.dbf 文件 打开得文件不能修改只能读取属性
 *
 *  @param path 文件路径
 *
 *  @return 初始化 STShapeDataBase 打开失败返回nil
 */
+ (instancetype)openDatabaseWithPath:(NSString *)path;

/*!
 *  创建一个.dbf 文件  文件不存在 创建文件，如果存在创建文件覆盖源文件
 *
 *  @param path     文件路径
 *
 *  @return 初始化 STShapeDataBase 创建失败返回nil
 */
+ (instancetype)createDatabaseWithPath:(NSString *)path;


/*!
 *  通过索引查询一条记录的属性
 *
 *  @param index 要查得索引
 *
 *  @return 返回 记录字典 key值为属性名
 */
- (NSDictionary *)attributeForIndex:(int)index;


#pragma mark -只有通过 createDatabaseWithPath 创建的文件才能 调用此接口


/*!
 *  添加一条记录
 *
 *  @param dic key值为属性名 valal 为要添加属性对应的值， double inter 类型 对应 nsnumber 对象
 */

- (void)addColumn:(NSDictionary*)dic;

/*!
 *  添加一个属性
 *
 *  @param field     属性名称 （最大支持12个字节）
 *  @param type      数据类型
 *  @param width     占几位
 *  @param nDecimals 小数点位数(注意：只有FTDouble类型此大于1，其余都为0)
 *
 *  @return 成功返回yes 失败返回 no
 */
- (BOOL)addField:(NSString*)field type:(DBFFieldType)type width:(int)width decimals:(int) nDecimals;

@end
