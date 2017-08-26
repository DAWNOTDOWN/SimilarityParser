//
//  Parser.m
//  similarityParser
//
//  Created by 方阳 on 2017/8/14.
//  Copyright © 2017年 yyplatform. All rights reserved.
//

#import "Parser.h"
#import "SimilarModel.h"
#import "SymbolModel.h"

@interface Parser()

@property (nonatomic,assign) NSUInteger dataOffset;
@property (nonatomic,strong) NSString* srcPath;

@end

@implementation Parser

+ (instancetype)sharedParser;
{
    static Parser* p = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        p = [Parser new];
    });
    return p;
}

- (void)parseSrcPath:(NSString*)path
{
    NSURL* url = [NSURL fileURLWithPath:path];
    if( !url )
    {
        NSLog(@"invalid url:%@",path);
        return;
    }
    self.srcPath = path;
    NSString* similarPath = [NSString stringWithFormat:@"%@/similar.txt",path];
    NSString* content = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:similarPath isDirectory:NO] encoding:NSMacOSRomanStringEncoding error:nil];
    if( !content )
    {
        NSLog(@"invalid similar file path");
        return;
    }
    NSArray* lines = [content componentsSeparatedByString:@"\n"];
    BOOL files = NO;
    SimilarModel* model = nil;
    NSMutableArray* arr = [NSMutableArray new];
    for( NSString* line in lines )
    {
        if( [line hasSuffix:@"files:"] )
        {
            files = YES;
            if( model )
            {
                [arr addObject:model];
            }
            model = [SimilarModel new];
            NSArray* similarlines = [line componentsSeparatedByString:@" "];
            model.similarLines = [similarlines[1] integerValue];
        }
        else if( files )
        {
            if( [line hasSuffix:@".m"] || [line hasSuffix:@".mm"] )
            {
                NSArray* components = [line componentsSeparatedByString:@" "];
                if( ![[components lastObject] hasPrefix:@"/Users"] )
                {
                    
                }
                [model.items addObject:line];
            }
            else
            {
                files = NO;
                if( model )
                {
                    [arr addObject:model];
                }
                model = nil;
            }
        }
        else
        {
            files = NO;
            if( model )
            {
                [arr addObject:model];
            }
            model = nil;
        }
    }
    
    NSString* linkmapFile = [NSString stringWithFormat:@"%@/LinkMap-arm64.txt",path];
    NSString* linkmapContent = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:linkmapFile isDirectory:NO] encoding:NSMacOSRomanStringEncoding error:nil];
    if( !linkmapContent )
    {
        NSLog(@"invalid linkmap");
        return;
    }
    NSDictionary *symbolMap = [self symbolMapFromContent:linkmapContent];
    NSMutableDictionary* fileindexes = [NSMutableDictionary new];
    for( SymbolModel* model in [symbolMap allValues] )
    {
        NSString* name = [model.file lastPathComponent];
        if( [name hasSuffix:@")"] && [name containsString:@"("] )
        {
            NSRange lrange = [name rangeOfString:@"("];
            NSRange rrange = [name rangeOfString:@")"];
            NSString* rname = [name substringWithRange:NSMakeRange(lrange.location+1, rrange.location-lrange.location-1)];
            [fileindexes setObject:@"" forKey:[rname componentsSeparatedByString:@"."][0]];
        }
        else
        {
            [fileindexes setObject:@"" forKey:[name componentsSeparatedByString:@"."][0]];
        }
    }
    
    NSMutableArray* finalItems = [NSMutableArray new];
    for( SimilarModel* model in arr )
    {
        NSMutableArray* newitems = [NSMutableArray new];
        for( NSString* item in model.items )
        {
            NSString* path = [[[item componentsSeparatedByString:@" "] lastObject] lastPathComponent];
            path = [[path componentsSeparatedByString:@"."] firstObject];
            if( [fileindexes objectForKey:path] )
            {
                [newitems addObject:item];
            }
            else
            {
                
            }
        }
        if( newitems.count >= 2 )
        {
            model.items = newitems;
        }
        else
        {
            continue;
        }
        [finalItems addObject:model];
    }
    NSString* outputfilePath = [NSString stringWithFormat:@"%@/revised_similar.txt",path];
    NSMutableString* writestring = [NSMutableString new];
    for( SimilarModel* model in finalItems )
    {
        [writestring appendString:[NSString stringWithFormat:@"%@ lines in files:\n",@(model.similarLines)]];
        for( NSString* str in model.items  )
        {
            [writestring appendString:[NSString stringWithFormat:@"%@\n",str]];
        }
    }
    
    NSUInteger totalcount = 0;
    NSMutableDictionary* keywordcount = [@{@"/AppName/TemplatePlugin/MakeFriends/":@0,@"/AppName/TemplatePlugin/OnePiece/":@0,@"/AppName/Ui/Live/":@0,@"/AppName/Ui/MobileLive/":@0,@"/AppName/Ui/IM/":@0,@"/AppName/Ui/1931/":@0,@"/AppName/Ui/Base/":@0,@"/AppName/Ui/Channel/":@0,@"/AppName/Ui/Personal/":@0,@"/AppName/Ui/Settings/":@0,@"/AppName/Ui/Anchor/":@0,@"/AppName/Ui/Search/":@0,@"/AppName/Ui/Auth/":@0,@"/AppName/Ui/Accompaniment/":@0,@"/AppName/Ui/Dynamic/":@0,@"/AppName/Ui/Lab/":@0,@"/AppName/Ui/Store/":@0,@"/AppName/Ui/Main/":@0,@"/AppName/Ui/PayOne/":@0,@"/Pods/":@0} mutableCopy];
    NSMutableDictionary* keywordSearchDic = [NSMutableDictionary new];
    for( NSString* key in keywordcount )
    {
        NSMutableArray* arr = [[key componentsSeparatedByString:@"/"] mutableCopy];
        if( [[arr firstObject] length] == 0 && arr.count )
        {
            [arr removeObjectAtIndex:0];
        }
        if( [[arr lastObject] length] == 0 && arr.count )
        {
            [arr removeObjectAtIndex:arr.count-1];
        }
        Byte componentcount = arr.count;
        NSMutableDictionary* dst = keywordSearchDic;
        while( componentcount >= 1 )
        {
            NSArray* com = [arr subarrayWithRange:NSMakeRange(0, arr.count+1-componentcount)];
            NSString* join = [com componentsJoinedByString:@"_"];
            NSMutableDictionary* curDst = nil;
            if( ![dst objectForKey:join] )
            {
                curDst = [NSMutableDictionary new];
                [dst setObject:curDst forKey:join];
            }
            else
            {
                curDst = [dst objectForKey:join];
            }
            dst = curDst;
            componentcount--;
        }
        [dst setObject:key forKey:@""];
    }
    for( SimilarModel* model in finalItems )
    {
        for( NSString* item in model.items )
        {
            NSString* filepath = [[item componentsSeparatedByString:@" "] lastObject];
            NSRange range = [filepath rangeOfString:self.srcPath];
            NSString* path = [filepath substringFromIndex:range.location+range.length];
            NSMutableArray* arr = [[path componentsSeparatedByString:@"/"] mutableCopy];
            if( arr.count && [[arr firstObject] length] == 0 )
            {
                [arr removeObjectAtIndex:0];
            }
            Byte componentcount = arr.count;
            NSMutableDictionary* dst = keywordSearchDic;
            NSString* countKey = nil;
            while( componentcount > 1 )
            {
                NSArray* com = [arr subarrayWithRange:NSMakeRange(0, arr.count+1-componentcount)];
                NSString* join = [com componentsJoinedByString:@"_"];
                dst = [dst objectForKey:join];
                if( !dst )
                {
                    break;
                }
                if( [dst objectForKey:@""] )
                {
                    countKey = [dst objectForKey:@""];
                    break;
                }
                componentcount--;
            }
            
            if( countKey )
            {
                NSNumber* num =  keywordcount[countKey];
                keywordcount[countKey] = @(num.unsignedIntegerValue + model.similarLines);
            }
        }
        totalcount+= model.similarLines*model.items.count;
    }
    for( NSString* key in keywordcount )
    {
        [writestring appendString:[NSString stringWithFormat:@"%@ duplicated lines for keyword:%@\n",keywordcount[key],key]];
    }
    [writestring appendString:[NSString stringWithFormat:@"total duplicated lines:%@",@(totalcount)]];
    [writestring writeToURL:[NSURL fileURLWithPath:outputfilePath isDirectory:NO] atomically:YES encoding:NSUTF8StringEncoding error:nil];

}

- (NSMutableDictionary *)symbolMapFromContent:(NSString *)content
{
    NSMutableDictionary <NSString *,SymbolModel *>*symbolMap = [NSMutableDictionary new];
    // 符号文件列表
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    
    BOOL reachFiles = NO;
    BOOL reachSymbols = NO;
    BOOL reachSections = NO;
    self.dataOffset = 0;
    NSUInteger size = 0;
    for(NSString *line in lines) {
        if([line hasPrefix:@"#"]) {
            if([line hasPrefix:@"# Object files:"])
                reachFiles = YES;
            else if ([line hasPrefix:@"# Sections:"])
                reachSections = YES;
            else if ([line hasPrefix:@"# Symbols:"])
                reachSymbols = YES;
        } else {
            if(reachFiles == YES && reachSections == NO && reachSymbols == NO) {
                NSRange range = [line rangeOfString:@"]"];
                if(range.location != NSNotFound) {
                    SymbolModel *symbol = [SymbolModel new];
                    symbol.file = [line substringFromIndex:range.location+1];
                    NSString *key = [line substringToIndex:range.location+1];
                    symbolMap[key] = symbol;
                }
            }
            else if( reachFiles == YES && reachSections == YES && reachSymbols == NO )
            {
                NSArray <NSString *>*sectionArray = [line componentsSeparatedByString:@"\t"];
                if ( !self.dataOffset && sectionArray.count == 4  && [sectionArray[2] isEqualToString:@"__DATA"] ) {
                    self.dataOffset = strtoul([sectionArray[0] UTF8String], nil, 16);
                }
            }
            else if (reachFiles == YES && reachSections == YES && reachSymbols == YES) {
                NSArray <NSString *>*symbolsArray = [line componentsSeparatedByString:@"\t"];
                if(symbolsArray.count == 3) {
                    if( [symbolsArray[0] containsString:@"<<dead>>"] )
                    {
                        size++;
                        continue;
                    }
                    NSString *fileKeyAndName = symbolsArray[2];
                    NSUInteger size = strtoul([symbolsArray[1] UTF8String], nil, 16);
                    NSUInteger offset = strtoul([symbolsArray[0] UTF8String], nil, 16);
                    
                    NSRange range = [fileKeyAndName rangeOfString:@"]"];
                    if(range.location != NSNotFound) {
                        NSString *key = [fileKeyAndName substringToIndex:range.location+1];
                        SymbolModel *symbol = symbolMap[key];
                        if(symbol) {
                            symbol.size += size;
                            if( offset < self.dataOffset )
                            {
                                symbol.codeSize += size;
                            }
                        }
                    }
                }
            }
        }
    }
    return symbolMap;
}
@end
