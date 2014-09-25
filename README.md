Chinese-replace-and-extract
===========================

代码中文搜索，替换并提取 到.string 文件中 ，用于应用的多语言准备

哈哈哈哈  簡直爽到爆啊  先使用XIB提取中文  再用中文替換   就OK了    


修改下輸出的樣式 [sb appendFormat:@“\”%@\””]。。。就可以整個文件拿去 翻译了  

翻譯完就可以用注释的方法来合并

blog: http://blog.csdn.net/li6185377/article/details/39551389


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
