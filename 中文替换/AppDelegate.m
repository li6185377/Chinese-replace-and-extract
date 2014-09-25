//
//  AppDelegate.m
//  中文替换
//
//  Created by ljh on 14-9-23.
//  Copyright (c) 2014年 LJH. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property(strong,nonatomic)NSMutableDictionary* dic;
@property(strong,nonatomic)NSRegularExpression *regex;
@end

@implementation AppDelegate


-(void)replaceFileWithDir:(NSString*)dir
{
    NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    for (NSString* fileName in array)
    {
        NSString* newPath = [dir stringByAppendingPathComponent:fileName];
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:&isDir];
        if(isDir)
        {
            [self replaceFileWithDir:newPath];
        }
        else if([newPath.pathExtension isEqualToString:@"m"])
        {
            [self replaceFileWithPath:newPath];
        }
        else if([newPath.pathExtension isEqualToString:@"json"])
        {
            [self replaceFileWithJSONPath:newPath];
        }
    }
}
-(void)replaceFileWithJSONPath:(NSString*)path
{
    NSMutableString* fileContent = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if(fileContent.length == 0)
    {
        return;
    }
    NSString *regularStr = @"\"(?:(\\\\\"|[^\"]|[\\r\\n]))*\"";
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSArray* matches = [regex matchesInString:fileContent.lowercaseString options:0 range:NSMakeRange(0, fileContent.length)];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange range = [match range];
        NSString* subStr = [fileContent substringWithRange:range];
        
        BOOL zhongwen = NO;
        for(int i=0; i< subStr.length;i++){
            int a = [subStr characterAtIndex:i];
            if( a > 0x4e00 && a < 0x9fff)
            {
                zhongwen = YES;
            }
        }
        if(zhongwen == NO)
        {
            continue;
        }
        
        subStr = [subStr substringWithRange:NSMakeRange(1, subStr.length - 2)];
        [_dic setObject:subStr forKey:subStr];
    }
    NSLog(@"%@ ok \n",path);
}

-(void)replaceFileWithPath:(NSString*)path
{
    NSMutableString* fileContent = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if(fileContent.length == 0)
    {
        return;
    }
    int offset = 0;
    NSString *regularStr = @"@\"(?:(\\\\\"|[^\"]|[\\r\\n]))*\"";
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSArray* matches = [regex matchesInString:fileContent.lowercaseString options:0 range:NSMakeRange(0, fileContent.length)];
    BOOL hasChange = NO;
    for (NSTextCheckingResult *match in matches)
    {
        NSRange range = [match range];
        range.location += offset;
        
        int location = (int)range.location - 6;
        if(location >= 0)
        {
            NSString* qq = [fileContent substringWithRange:NSMakeRange(location, 6)];
            if([qq isEqualToString:@"NSLog("])
            {
                continue;
            }
        }
        
        NSString* subStr = [fileContent substringWithRange:range];
        
        BOOL zhongwen = NO;
        for(int i=0; i< subStr.length;i++){
            int a = [subStr characterAtIndex:i];
            if( a > 0x4e00 && a < 0x9fff)
            {
                zhongwen = YES;
            }
        }
        if(zhongwen == NO)
        {
            continue;
        }
        
        location = (int)range.location - 7;
        NSString* checkStr = [fileContent substringWithRange:NSMakeRange(location, 7)];
        if([checkStr isEqualToString:@"SY_STR("])
        {
            subStr = [subStr substringWithRange:NSMakeRange(2, subStr.length - 3)];
            [_dic setObject:subStr forKey:subStr];
            continue;
        }
        
        NSString* replaceStr = [NSString stringWithFormat:@"SY_STR(%@)",subStr];

        offset += replaceStr.length - subStr.length;
        
        [fileContent replaceCharactersInRange:range withString:replaceStr];
        
        subStr = [subStr substringWithRange:NSMakeRange(2, subStr.length - 3)];
        [_dic setObject:subStr forKey:subStr];
        hasChange = YES;
    }
    NSLog(@"%@ ok \n",path);
    if(hasChange)
    {
        [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [self pingjieJianTiPath:@"/Users/linyunfeng/Documents/code_git/work4/jianti.strings" fantiPath:@"/Users/linyunfeng/Documents/code_git/work4/fanti.strings"];
    
    [self tiquZhongWen];
}

-(void)tiquZhongWen
{
    self.dic = [NSMutableDictionary dictionary];
    ///目錄
    NSString* dirPath = @"/Users/linyunfeng/Documents/code_git/work4/iPhone/Meetyou_iPhone/Seeyou/";
    [self replaceFileWithDir:dirPath];
    
    
    NSMutableString* sb = [NSMutableString string];
    [_dic enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
        NSString* jjj = [key stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        NSString* bbb = [obj stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        [sb appendFormat:@"\"%@\" = \"%@\";\n",jjj,bbb];
    }];
    
    [sb writeToFile:[dirPath stringByAppendingPathComponent:@"local.strings"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)pingjieJianTiPath:(NSString*)jianPath fantiPath:(NSString*)fanPath
{
    NSString* jiantiContent = [NSString stringWithContentsOfFile:jianPath encoding:NSUTF8StringEncoding error:nil];
    NSArray* jianArray = [jiantiContent componentsSeparatedByString:@"\n"];
    
    NSString* fantiContent = [NSString stringWithContentsOfFile:fanPath encoding:NSUTF8StringEncoding error:nil];
    NSArray* fanArray = [fantiContent componentsSeparatedByString:@"\n"];
    
    if(jianArray.count != fanArray.count)
    {
        return;
    }
    
    NSMutableString* sb = [NSMutableString string];
    for (int i = 0; i< jianArray.count; i++)
    {
        NSString* jjj = [jianArray objectAtIndex:i];
        NSString* fff = [fanArray objectAtIndex:i];
        if([jjj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            continue;
        }
        [sb appendFormat:@"%@ = %@;\n",jjj,fff];
    }
    
    [sb writeToFile:[jianPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"local2.strings"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
