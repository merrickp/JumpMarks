//
//  JumpMarkList.m
//  JumpMarks
//
//  Created by Merrick Poon on 3/22/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import "JumpMarkList.h"

@interface JumpMarkList ()

@property(strong, nonatomic) NSMutableDictionary *marksDict;

@end

@implementation JumpMarkList

- (instancetype)init {
    self = [super init];
    if(self) {
        _marksDict = [NSMutableDictionary new];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static JumpMarkList* instance;
    if(!instance) {
        instance = [[JumpMarkList alloc] init];
    }
    return instance;
}  

#pragma mark - Persistence methods

- (NSString *)projectFilePath {
    NSWindowController *mainWindowController = [[NSApp mainWindow] windowController];
    id workspace = [mainWindowController valueForKey:@"_workspace"];
    id customDatastore = [workspace valueForKey:@"_customDataStore"];
    id customDatapath = [customDatastore valueForKey:@"_customDataPath"];
    id filePath = [customDatapath valueForKey:@"_pathString"];

    if([filePath isKindOfClass:[NSString class]]) {
        NSString *path = [NSString pathWithComponents:@[filePath, [NSUserName() stringByAppendingPathExtension:@"jumpmarks"]]];
        return path;
    }
    return nil;
}

- (void)load {
    NSString *projectFilePath = [self projectFilePath];
    if (projectFilePath) {
        id data = [NSKeyedUnarchiver unarchiveObjectWithFile:projectFilePath];
        NSLog(@"%@", data);
    }
}

- (void)flush {
    NSString *projectFilePath = [self projectFilePath];
    if (projectFilePath) {
        [NSKeyedArchiver archiveRootObject:[_marksDict allValues] toFile:projectFilePath];
    }
}

#pragma mark - Mark retrieval

- (JumpMark*)getMarkNumber:(NSInteger)markNumber {
    return _marksDict[@(markNumber)];
}

- (void)toggleMarkNumber:(NSInteger)markNumber filePath:(NSString *)filePath lineNumber:(NSInteger)lineNumber {
    JumpMark *existingMark = [self getMarkNumber:markNumber];
    if(existingMark) {
        [self removeMarkNumber:markNumber];
        return;
    }
    _marksDict[@(markNumber)] =  [JumpMark textEditorMark:filePath lineNumber:lineNumber markNumber:markNumber];
}

- (void)removeMarkNumber:(NSInteger)markNumber {
    [_marksDict removeObjectForKey:@(markNumber)];
}

- (NSArray *)marksForFilePath:(NSString *)filePath {
    NSArray *keys = [[_marksDict keysOfEntriesPassingTest:^BOOL(id key, JumpMark *mark, BOOL *stop) {
        return [filePath isEqualToString:mark.filePath];
    }] allObjects];
    if([keys count]) {
        return [_marksDict objectsForKeys:keys notFoundMarker:[NSNull null]];
    } else {
        return @[];
    }
}

@end
