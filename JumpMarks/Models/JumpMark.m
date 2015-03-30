//
//  JumpMark.m
//  JumpMarks
//
//  Created by Merrick Poon on 3/22/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import "JumpMark.h"

@implementation JumpMark

#pragma mark - NSCoding methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.filePath = [aDecoder decodeObjectForKey:@"filePath"];
        self.lineNumber = [aDecoder decodeIntegerForKey:@"lineNumber"];
        self.markNumber = [aDecoder decodeIntegerForKey:@"markNumber"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_type forKey:@"type"];
    [aCoder encodeObject:_filePath forKey:@"filePath"];
    [aCoder encodeInteger:_lineNumber forKey:@"lineNumber"];
    [aCoder encodeInteger:_markNumber forKey:@"markNumber"];
}

#pragma mark - Helper initializers

+ (instancetype)textEditorMark:(NSString*)filePath lineNumber:(NSInteger)lineNumber
                    markNumber:(NSInteger)markNumber{
    JumpMark *mark = [self alloc];
    mark.type = JumpMarkTypeTextEditor;
    mark.filePath = filePath;
    mark.lineNumber = lineNumber;
    mark.markNumber = markNumber;
    return mark; 
}

@end
