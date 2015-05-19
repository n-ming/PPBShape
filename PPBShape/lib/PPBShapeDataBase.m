//
//  PPBShapeDataBase.m
//  PPBShape
//
//  Created by showtekwh on 15/5/19.
//
//

#import "PPBShapeDataBase.h"

@interface PPBShapeDataBase ()

@property DBFHandle handle;
@property (nonatomic,copy) NSString *errorInfo;
@end

@implementation PPBShapeDataBase
@synthesize records = _records;
@synthesize fields = _fields;
+ (instancetype)openDatabaseWithPath:(NSString *)path;
{
    PPBShapeDataBase *db = [[PPBShapeDataBase alloc] initAndOpenDatabaseWithPath:path];
    return db;
}
+ (instancetype)createDatabaseWithPath:(NSString *)path;
{
    PPBShapeDataBase *db = [[PPBShapeDataBase alloc] initAndCreateDatabaseWithPath:path];
    return db;
}

- (instancetype)initAndOpenDatabaseWithPath:(NSString *)path;
{
    self = [super init];
    if (!path) {
        return nil;
    }
    _handle = DBFOpen([path cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (_handle == NULL) {
        return nil;
    }
    _isCreate = NO;
    self.stringEncoding = NSUTF8StringEncoding;
    return self;
}
- (instancetype)initAndCreateDatabaseWithPath:(NSString *)path;
{
    self = [super init];
    if (!path) {
        return nil;
    }
    _handle = DBFCreate([path cStringUsingEncoding:NSUTF8StringEncoding]);
    if (_handle == NULL) {
        return nil;
    }
    _isCreate = YES;
    self.stringEncoding = NSUTF8StringEncoding;
    
    return self;
}

- (BOOL)addField:(NSString*)field type:(DBFFieldType)type width:(int)width decimals:(int) nDecimals
{
    if (!_handle || field.length <1) {
        return NO;
    }
    int res =DBFAddField(_handle, [field cStringUsingEncoding:self.stringEncoding], type, width, nDecimals);
    
    if (res < 0) {
        return NO;
    }
    
    return YES;
    
}

- (void)addColumn:(NSDictionary*)dic;
{
    if (!_handle || dic == nil  || !self.isCreate) {
        return;
    }
    NSArray *arr = [dic allKeys];
    int recordCount = self.recordsCount;
    for (NSString *key in arr) {
        id obj = [dic objectForKey:key];
        if ([obj isKindOfClass:[NSString class]]) {
            [self writeStringAttribute:obj field:key record:recordCount];
        } else if ([obj isKindOfClass:[NSNumber class]]){
            
            if (strcmp([obj objCType], @encode(int)) == 0) {
                [self writeIntegerAttribute:[obj intValue] field:key record:recordCount];
            }
            else if (strcmp([obj objCType], @encode(unsigned int)) == 0) {
                [self writeIntegerAttribute:[obj intValue] field:key record:recordCount];
            }
            else if (strcmp([obj objCType], @encode(long)) == 0) {
                [self writeIntegerAttribute:[obj intValue] field:key record:recordCount];
            }
            else if (strcmp([obj objCType], @encode(unsigned long)) == 0) {
                [self writeIntegerAttribute:[obj intValue] field:key record:recordCount];
            }
            else if (strcmp([obj objCType], @encode(long long)) == 0) {
                [self writeIntegerAttribute:[obj intValue] field:key record:recordCount];
            }
            else if (strcmp([obj objCType], @encode(unsigned long long)) == 0) {
                [self writeIntegerAttribute:[obj intValue] field:key record:recordCount];
            }
            else if (strcmp([obj objCType], @encode(float)) == 0) {
                [self writeDoubleAttribute:[obj doubleValue] field:key record:recordCount];
            }
            else if (strcmp([obj objCType], @encode(double)) == 0) {
                [self writeDoubleAttribute:[obj doubleValue] field:key record:recordCount];
                
            }
        }
    }
    
}

- (int)fieldIndex:(NSString*)field
{
    if (!_handle || !field  ) {
        return -1;
    }
    return  DBFGetFieldIndex(_handle, [field cStringUsingEncoding:self.stringEncoding]);
}

- (void)dealloc
{
    [self close];
}

- (NSUInteger)fieldCount
{
    if (_handle == NULL) {
        return 0;
    }
    return DBFGetFieldCount(_handle);
}

- (NSArray *)fields
{
    if (_handle == NULL) {
        return nil;
    }
    
    NSMutableArray *mutableFieldsArray = [NSMutableArray array];
    char title[12];
    int width;
    int decimals;
    for(int i = 0; i < DBFGetFieldCount(_handle); i++){
        DBFGetFieldInfo( _handle, i, title, &width, &decimals );
        [mutableFieldsArray addObject:[NSString stringWithCString:title encoding:self.stringEncoding]];
    }
    _fields = [NSArray arrayWithArray:mutableFieldsArray];
    return _fields;
}

- (int)recordsCount
{
    if (_handle == NULL) {
        return 0;
    }
    return DBFGetRecordCount(_handle);
}

- (NSArray *)records
{
    if (_handle == NULL) {
        return nil;
    }
    if (_records && !self.isCreate) {
        return _records;
    }
    NSMutableArray *mutableRecordsArray = [NSMutableArray array];
    for (int count = 0; count < self.recordsCount; count++) {
        NSDictionary *recordDictionary = [self attributeForIndex:count];
        if (recordDictionary) {
            [mutableRecordsArray addObject:recordDictionary];
        }
    }
    _records = [NSArray arrayWithArray:mutableRecordsArray];
    return _records;
}

- (NSDictionary *)attributeForIndex:(int)index;
{
    if (!_handle || self.recordsCount <= index ) {
        return nil;
    }
    char title[12];
    int width;
    int decimals;
    NSMutableDictionary *recordDictionary = [NSMutableDictionary dictionary];
    for (int count = 0; count < self.fieldCount; count++){
        DBFFieldType type = DBFGetFieldInfo( _handle, count,title, &width, &decimals );
        NSString *fieldTitle = [NSString stringWithUTF8String:title];
        if (DBFIsAttributeNULL( _handle, index, count )) {
            [recordDictionary setObject:[NSNull null] forKey:fieldTitle];
        }else{
            switch (type) {
                case FTString:
                {
                    const char *c = DBFReadStringAttribute(_handle, index, count);
                    NSString *s = [self stringWithCharacter:c ];
                    if (s) {
                        [recordDictionary setObject:s forKey:fieldTitle];
                    } else {
                        [recordDictionary setObject:[NSNull null] forKey:fieldTitle];
                        
                        self.errorInfo = [NSString stringWithFormat:@"%@ 字符串解码失败" ,fieldTitle];
                        NSLog(@"字符串解码失败");
                    }
                }
                    break;
                case FTInteger:
                {
                    int res = DBFReadIntegerAttribute(_handle, index, count);
                    [recordDictionary setObject:[NSNumber numberWithInt:res] forKey:fieldTitle];
                }
                    break;
                case FTDouble:
                {
                    double res = DBFReadDoubleAttribute(_handle, index, count);
                    [recordDictionary setObject:[NSNumber numberWithDouble:res] forKey:fieldTitle];
                }
                    break;
                default:
                    break;
            }
        }
    }
    
    if ([recordDictionary count] > 0) {
        return recordDictionary;
    }
    return nil;
}


- (void)close
{
    if (_handle) {
        DBFClose(_handle);
        _handle = NULL;
    }
    
}

#pragma mark - 写属性 接口

- (BOOL)writeDoubleAttribute:(double)attr  field:(NSString*)field record:(int)count
{
    if (!_handle  || !field   || !self.isCreate) {
        return NO;
    }
    
    int index = [self fieldIndex:field];
    if (index < 0) {
        return NO;
    }
    return DBFWriteDoubleAttribute(_handle, count, index, attr);
    
}
- (BOOL)writeIntegerAttribute:(int)attr field:(NSString*)field record:(int)count
{
    if (!_handle  || !field   || !self.isCreate) {
        return NO;
    }
    
    int index = [self fieldIndex:field];
    if (index < 0) {
        return NO;
    }
    
    return DBFWriteIntegerAttribute(_handle, count, index, attr);
}


- (BOOL)writeStringAttribute:(NSString*)attr field:(NSString*)field record:(int)count
{
    if (!_handle || !attr || !field  || !self.isCreate) {
        return NO;
    }
    
    int index = [self fieldIndex:field];
    if (index < 0) {
        return NO;
    }
    
    return  DBFWriteStringAttribute( _handle,count, index,
                                    [attr cStringUsingEncoding:self.stringEncoding] );
    
}

- (BOOL)writeStringAttribute:(NSString*)attr index:(int)index record:(int)count
{
    if (!_handle || self.recordsCount <= index  || !self.isCreate) {
        return NO;
    }
    
    return  DBFWriteStringAttribute( _handle,count, index,
                                    [attr cStringUsingEncoding:NSUTF8StringEncoding] );
}

- (BOOL)writeDoubleAttribute:(double)attr index:(int)index record:(int)count
{
    if (!_handle || self.recordsCount <= index  || !self.isCreate)  {
        return NO;
    }
    
    return DBFWriteDoubleAttribute(_handle, count, index, attr);
}
- (BOOL)writeIntegerAttribute:(int)attr index:(int)index record:(int)count
{
    if (!_handle || self.recordsCount <= index  || !self.isCreate) {
        return NO;
    }
    
    return DBFWriteIntegerAttribute(_handle, count, index,attr);
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"属性数量 : %ld\n 属性名\n: %@\n 记录条数 : %d", (unsigned long)self.fieldCount, self.fields, self.recordsCount];
}

- (NSString*)lastErrorMessage;
{
    return nil;
}

- (NSString*)stringWithCharacter:(const char *)c
{
    
    if (!c) {
        return nil;
    }
    NSString*  s =  [NSString stringWithCString:c encoding:self.stringEncoding];
    return s;
    
    //    if (!s) {
    //        s =  [NSString stringWithCString:c encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    //    }
    //
    //    if (!s) {
    //        s =  [NSString stringWithCString:c encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80)];
    //    }
    //
    //    if (!s) {
    //        s =  [NSString stringWithCString:c encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGBK_95)];
    //    }
    //    
    //    return s;
}

@end
