Chinese-replace-and-extract
===========================

代码中文搜索，替换并提取 到.string 文件中 ，用于应用的多语言准备


使用方法  把  目录改为你应用的目录  
```objective-c
    ///目錄
    NSString* dirPath = @"/Users/linyunfeng/Documents/code_git/work4/iPhone/Meetyou_iPhone/Seeyou/";
    [self replaceFileWithDir:dirPath];
```

替换的样式 你自己修改下
```objective-c
        ...
            if([qq isEqualToString:@"NSLog("] || [qq isEqualToString:@"Y_STR("])
            {
                continue;
            }
        ...
        ...
        NSString* replaceStr = [NSString stringWithFormat:@"SY_STR(%@)",subStr];
        ...
```
