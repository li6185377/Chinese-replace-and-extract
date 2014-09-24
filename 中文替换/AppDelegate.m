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
    }
}

-(void)replaceFileWithPath:(NSString*)path
{
    NSMutableString* fileContent = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
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
        
        NSString* checkStr = [fileContent substringWithRange:NSMakeRange(location, 7)];
        if([checkStr isEqualToString:@"SY_STR("])
        {
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
    self.dic = [NSMutableDictionary dictionary];
    ///目錄
    NSString* dirPath = @"/Users/linyunfeng/Documents/code_git/work4/iPhone/Meetyou_iPhone/Seeyou/";
    [self replaceFileWithDir:dirPath];
    
    
    NSMutableString* sb = [NSMutableString string];
    [_dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [sb appendFormat:@"\"%@\" = \"%@\";\n",key,obj];
    }];
    
    [sb writeToFile:[dirPath stringByAppendingPathComponent:@"local.strings"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
