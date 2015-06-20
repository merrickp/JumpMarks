//
//  JumpMarkList.m
//  JumpMarks
//
//  Created by Merrick Poon on 3/22/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import "JumpMarkList.h"
#import "IDEKit.h"

@interface JumpMarkList ()

@property(strong, nonatomic) NSMutableDictionary *marksDict;

@end

@implementation JumpMarkList

- (instancetype)initWithCustomDataPath:(NSString*)customDataPath {
    self = [super init];
    if(self) {
        _marksDict = [NSMutableDictionary new];
        _customDataPath = customDataPath;
        _filePath = [NSString pathWithComponents:@[customDataPath,
                                                   [NSUserName() stringByAppendingPathExtension:@"jumpmarks"]]];
        [self load];
    }
    return self;
}

#pragma mark - Persistence methods

- (void)load {
    if(_filePath) {
        id data = [NSKeyedUnarchiver unarchiveObjectWithFile:_filePath];
        if([data isKindOfClass:[NSDictionary class]]) {
            [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if([key isKindOfClass:[NSNumber class]] && [obj isKindOfClass:[JumpMark class]]) {
                    _marksDict[key] = obj;
                }
            }];
        }
    }
}

- (void)flush {
	if (_filePath) {
		NSDictionary *archiveDict = [_marksDict copy];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			[NSKeyedArchiver archiveRootObject:archiveDict toFile:_filePath];
		});
	}
}

#pragma mark - Mark manipulation/retrieval

- (JumpMark*)getMarkNumber:(NSInteger)markNumber {
    return _marksDict[@(markNumber)];
}

- (void)toggleMarkNumber:(NSInteger)markNumber filePath:(NSString *)filePath lineNumber:(NSInteger)lineNumber {
	JumpMark *duplicateMark = [self markForFilePath:filePath lineNumber:lineNumber];
	if(duplicateMark) {
		[self removeMarkNumber:duplicateMark.markNumber];
		if(duplicateMark.markNumber == markNumber) {
			return;
		}
	}
    _marksDict[@(markNumber)] =  [JumpMark textEditorMark:filePath lineNumber:lineNumber markNumber:markNumber];
}

- (void)removeMarkNumber:(NSInteger)markNumber {
    [_marksDict removeObjectForKey:@(markNumber)];
}

- (void)removeAllMarks {
	[_marksDict removeAllObjects];
}

- (NSNumber*)getNextMarkNumber:(NSInteger)lastMarkNumber {
	NSArray *keys = [[_marksDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
	for(NSNumber *key in keys) {
		if([key integerValue] > lastMarkNumber)
			return key;
	}
	// return wrapped value or nil
	return [keys firstObject];
}

- (NSNumber*)getPrevMarkNumber:(NSInteger)lastMarkNumber {
	NSArray *keys = [[_marksDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
	for(NSNumber *key in [keys reverseObjectEnumerator]) {
		if([key integerValue] < lastMarkNumber)
			return key;
	}
	// return wrapped value or nil
	return [keys lastObject];
}

- (NSArray *)marksForFilePath:(NSString *)filePath {
	return [_marksDict objectsForKeys:[[_marksDict keysOfEntriesPassingTest:^BOOL(id key, JumpMark *mark, BOOL *stop) {
		return [filePath isEqualToString:mark.filePath];
	}] allObjects] notFoundMarker:[NSNull null]];
}

- (JumpMark*)markForFilePath:(NSString *)filePath lineNumber:(NSInteger)lineNumber {
	for(JumpMark* mark in [_marksDict objectEnumerator]) {
		if([filePath isEqualToString:mark.filePath] && lineNumber == mark.lineNumber) {
			return mark;
		}
	}
	return nil;
}

@end
