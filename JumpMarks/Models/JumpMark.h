//
//  JumpMark.h
//  JumpMarks
//
//  Created by Merrick Poon on 3/22/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JumpMarkType) {
    JumpMarkTypeTextEditor
};

@interface JumpMark : NSObject <NSCoding>

@property(nonatomic) JumpMarkType type;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic) NSInteger lineNumber;
@property(nonatomic) NSInteger markNumber;

+ (instancetype)textEditorMark:(NSString*)filePath lineNumber:(NSInteger)lineNumber
                    markNumber:(NSInteger)markNumber;

@end
