//
//  PPBShapeFile.m
//  PPBShape
//
//  Created by showtekwh on 15/5/19.
//
//

#import "PPBShapeFile.h"
#import "PPBShapePoint.h"
#import "shapefil.h"
@interface PPBShapeFile ()

@property SHPHandle handle;
@end

@implementation PPBShapeFile
+ (instancetype)openShapeFileWithPath:(NSString *)path;
{
    PPBShapeFile *file = [[PPBShapeFile alloc ] initAndOpenShapeFileWithPath:path];
    
    return file;
}

+ (instancetype)createShapeFileWithPath:(NSString *)path  Type :(int)nSHPType;
{
    PPBShapeFile *file = [[PPBShapeFile alloc] initAndCreateShapeFileWithPath:path Type:nSHPType];
    return file;
}

#pragma mark -

- (instancetype)initAndOpenShapeFileWithPath:(NSString *)path;
{
    self = [super init];
    if (!path) {
        return nil;
    }
    _handle = SHPOpen([path cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    
    if (_handle == NULL) {
        return nil;
    }
    
    double 	minBound[4], maxBound[4];
    int shpcnt = 0;
    SHPGetInfo( _handle, &shpcnt, &_shapeType, minBound, maxBound );
    _shapePath  = [path copy];
    _isCreate   = NO;
    return self;
}

- (int)shapeCount
{
    if (_handle == NULL) {
        return 0;
    }
    return _handle->nRecords;
}
- (instancetype)initAndCreateShapeFileWithPath:(NSString *)path  Type :(int)nSHPType;
{
    self = [super init];
    if (!path) {
        return nil;
    }
    _handle = SHPCreate( [path cStringUsingEncoding:NSUTF8StringEncoding], nSHPType ) ;
    if (_handle == NULL) {
        return nil;
    }
    _shapeType  = nSHPType;
    _shapePath  = [path copy];
    _isCreate   = YES;
    
    return self;
}

#pragma mark -

- (BOOL)addShapeObject:(NSArray*)points;
{
    int nResult = -1;
    if ( _handle != NULL && points.count > 0 && self.isCreate)
    {
        if (_shapeType == SHPT_POLYGON ||  _shapeType == SHPT_ARC ) {
            NSInteger count = [points count];
            double	x[count], y[count];
            double  z;
            int		i;
            
            for(i = 0 ;i < count; i++){
                x[i]= ((PPBShapePoint*)points[i]).lat;
                y[i] = ((PPBShapePoint*)points[i]).lon;
            }
            SHPObject	*psShape;
            psShape = SHPCreateObject(_shapeType, -1, 0, NULL, NULL,
                                      (int)count, x, y, &z, &z );
            nResult =   SHPWriteObject( _handle, -1, psShape );
            SHPDestroyObject( psShape );
            psShape = NULL;
        } else if (_shapeType == SHPT_POINT){
            
            CLLocationCoordinate2D  lonlat = [[points firstObject] coordinate];
            SHPObject	*psShape;
            double z, m;
            z = 3.0;
            m = 4.0;
            psShape = SHPCreateObject( _shapeType, -1, 0, NULL, NULL,
                                      1, &lonlat.latitude, &lonlat.longitude, &z, &m );
            nResult  = SHPWriteObject( _handle, -1, psShape );
            SHPDestroyObject( psShape );
            psShape = NULL;
        }
        
    }
    if (nResult < 0){
        return NO;
    }else {
        return YES;
    }
}

- (void)dealloc
{
    [self close];
}

- (void)close
{
    if (_handle) {
        SHPClose(_handle);
        _handle = NULL;
    }
    
    _shapeType = 0;
}

- (NSString *)shapeName
{
    if (_handle == NULL) {
        return nil;
    }
    return [NSString stringWithUTF8String:SHPTypeName(self.shapeType)];
}

- (SHPObject)shapeObjectForIndex:(NSUInteger)index
{
    if (index >= self.shapeCount) {
        SHPObject shp;
        return shp;
    }
    if (_handle == NULL) {
        SHPObject shp;
        return shp;
    }
    return *SHPReadObject(_handle, (int)index);
}



- (NSArray *)coordinatesForIndex:(NSUInteger)index
{
    if (index >= self.shapeCount) {
        return nil;
    }
    NSMutableArray *mutableArray = [NSMutableArray array];
    SHPObject shapeObject = [self shapeObjectForIndex:index];
    int numCoordinates = shapeObject.nVertices;
    for (int i = 0; i < numCoordinates; i++) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(shapeObject.padfY[i], shapeObject.padfX[i]);
        [mutableArray addObject:[[PPBShapePoint alloc] initWithCoorinate:coordinate]];
    }
    return [NSArray arrayWithArray:mutableArray];
}

@end
