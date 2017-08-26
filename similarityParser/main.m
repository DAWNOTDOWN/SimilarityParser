//
//  main.m
//  similarityParser
//
//  Created by 方阳 on 2017/8/14.
//  Copyright © 2017年 yyplatform. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"

/* http://www.harukizaemon.com/simian/installation.html#cli */

/* 安装java即可扫描指定目录重复代码,毋需指定生成结果格式，分析代码中依赖了simian的默认结果格式,将结果按文件名similar.txt输出，运行后结果为revised_similar.txt */
// 参考命令如下：
//     java -jar simian-2.5.1.jar -includes=**/*.m **/*.mm -threshold=10 >similar.txt
 

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[Parser sharedParser] parseSrcPath:@"/Users/fangyang/srcfolder/ios/project"];
    }
    return 0;
}
