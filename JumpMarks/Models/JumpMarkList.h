//
//  JumpMarkList.h
//  JumpMarks
//
//  Created by Merrick Poon on 3/22/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JumpMark.h"

@interface JumpMarkList : NSObject

+ (instancetype)sharedInstance;

// The marks should be stored with the associated Xcode project's custom data path.
@property (nonatomic, strong) NSString *customDataPath;
@property (nonatomic, strong) NSString *filePath;

// Persistence
- (void)load;
- (void)flush;

// Manipulation
- (NSArray*)marksForFilePath:(NSString*)filePath;
- (JumpMark*)getMarkNumber:(NSInteger)markNumber;
- (NSNumber*)getPrevMarkNumber:(NSInteger)lastMarkNumber;
- (NSNumber*)getNextMarkNumber:(NSInteger)lastMarkNumber;

// Retrieval
- (void)toggleMarkNumber:(NSInteger)markNumber filePath:(NSString*)filePath lineNumber:(NSInteger)lineNumber;
- (void)removeMarkNumber:(NSInteger)markNumber;
- (void)removeAllMarks;

@end
