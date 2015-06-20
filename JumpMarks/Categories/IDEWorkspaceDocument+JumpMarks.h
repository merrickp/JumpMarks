//
//  IDEWorkspaceDocument+JumpMarks.h
//  JumpMarks
//
//  Created by Merrick Poon on 5/4/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import "IDEKit.h"
#import "IDEFoundation.h"
#import "JumpMarkList.h"

@interface IDEWorkspaceDocument (JumpMarks)

- (void)jumpmarks__setWorkspace:(IDEWorkspace*)arg1;

@end

@interface IDEWorkspace (JumpMarks)

@property(nonatomic, strong) JumpMarkList *jumpMarks;

@end