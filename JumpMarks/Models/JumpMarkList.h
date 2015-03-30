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

// Persistence
- (NSString*)projectFilePath; // The marks should be stored with the associated Xcode project's custom data path.
- (void)load;
- (void)flush;

- (NSArray*)marksForFilePath:(NSString*)filePath;
- (void)toggleMarkNumber:(NSInteger)markNumber filePath:(NSString*)filePath lineNumber:(NSInteger)lineNumber;
- (void)removeMarkNumber:(NSInteger)markNumber;
- (JumpMark*)getMarkNumber:(NSInteger)markNumber;

@end
