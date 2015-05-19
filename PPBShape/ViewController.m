//
//  ViewController.m
//  PPBShape
//
//  Created by showtekwh on 15/5/19.
//
//

#import "ViewController.h"
#import "PPBShapeKit.h"
@interface ViewController ()

@end

@implementation ViewController


//获取Documents目录地址
-(NSString *)fileDocumentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (void)test{
    
    NSString *doc = [self fileDocumentsDirectory];
    NSString *strPath = [NSString stringWithFormat:@"%@/test.shp",doc];
    
    PPBShapeFile *shp = [PPBShapeFile openShapeFileWithPath:strPath];
    if(!shp){
        shp = [PPBShapeFile createShapeFileWithPath:strPath Type:1];
        
        
        PPBShapePoint *point = [PPBShapePoint shapePointWithCoorinate:CLLocationCoordinate2DMake(23, 111)];
        
        if ([shp addShapeObject:@[point]]) {
            NSLog(@"添加点成功");
        } else {
            NSLog(@"添加失败");
        }
        
        PPBShapePoint *point2 = [PPBShapePoint shapePointWithCoorinate:CLLocationCoordinate2DMake(33, 112)];
        if ([shp addShapeObject:@[point2]]) {
            NSLog(@"添加点成功");
        } else {
            NSLog(@"添加失败");
        }
    }
    
    PPBShapePoint *point = [PPBShapePoint shapePointWithCoorinate:CLLocationCoordinate2DMake(23.22, 111)];
    
    if ([shp addShapeObject:@[point]]) {
        NSLog(@"添加点成功");
    } else {
        NSLog(@"添加失败");
    }
    
    PPBShapePoint *point2 = [PPBShapePoint shapePointWithCoorinate:CLLocationCoordinate2DMake(33.33, 112)];
    if ([shp addShapeObject:@[point2]]) {
        NSLog(@"添加点成功");
    } else {
        NSLog(@"添加失败");
    }
    
    NSLog(@"%d,%@",shp.shapeCount ,shp.shapeName);
    
    for (int i = 0; i < shp.shapeCount; i++) {
        NSArray*arr = [shp coordinatesForIndex:i];
        NSLog(@"%@",arr);
        
    }
    NSString *strPath2 = [NSString stringWithFormat:@"%@/test.dbf",doc];
    PPBShapeDataBase *db = [PPBShapeDataBase openDatabaseWithPath:strPath2];
    if (!db) {
        db = [PPBShapeDataBase createDatabaseWithPath:strPath];
        if ([db addField:@"FTString" type:FTString width:30 decimals:0]) {
            NSLog(@"添属性 FTString成功");
        } else {
            NSLog(@"添属性 FTString失败");
        }
        
        if ([db addField:@"FTInteger" type:FTInteger width:12 decimals:0]) {
            NSLog(@"添属性 FTInteger成功");
        } else {
            NSLog(@"添属性 FTInteger失败");
        }
        if ([db addField:@"FTDouble" type:FTDouble width:12 decimals:3]) {
            NSLog(@"添属性FTDouble 成功");
        } else {
            NSLog(@"添属性FTDouble 失败");
        }
        
        db.stringEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
        NSDictionary*dic = [NSDictionary dictionaryWithObjects:@[@"属性2",[NSNumber numberWithInt:100],[NSNumber numberWithDouble:100.101] ]forKeys:@[@"FTString",@"FTInteger",@"FTDouble"]];
        
        [db addColumn:dic];
        
        ;
        NSDictionary*dic2 = [NSDictionary dictionaryWithObjects:@[@"属性2",[NSNumber numberWithInt:10],[NSNumber numberWithDouble:10.11] ]forKeys:@[@"FTString",@"FTInteger",@"FTDouble"]];
        [db addColumn:dic2];
        
    }
    db.stringEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSDictionary*dic = [NSDictionary dictionaryWithObjects:@[@"属性2",[NSNumber numberWithInt:100],[NSNumber numberWithDouble:100.101] ]forKeys:@[@"FTString",@"FTInteger",@"FTDouble"]];
    
    [db addColumn:dic];
    
    ;
    NSDictionary*dic2 = [NSDictionary dictionaryWithObjects:@[@"属性2",[NSNumber numberWithInt:10],[NSNumber numberWithDouble:10.11] ]forKeys:@[@"FTString",@"FTInteger",@"FTDouble"]];
    [db addColumn:dic2];
    db.stringEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    
    
    NSLog(@"%@",db);
    
    
    for (int i = 0; i < db.recordsCount; i++) {
        NSDictionary *dic = [db attributeForIndex:i];
        NSLog(@"%@",dic);
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
