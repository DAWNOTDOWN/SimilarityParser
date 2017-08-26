//
//  Parser.h
//  similarityParser
//
//  Created by 方阳 on 2017/8/14.
//  Copyright © 2017年 yyplatform. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Parser : NSObject

+ (instancetype)sharedParser;

- (void)parseSrcPath:(NSString*)path;

@end
