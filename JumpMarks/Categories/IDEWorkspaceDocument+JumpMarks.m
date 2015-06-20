//
//  IDEWorkspaceDocument+JumpMarks.m
//  JumpMarks
//
//  Created by Merrick Poon on 5/4/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import "IDEWorkspaceDocument+JumpMarks.h"
#import "JRSwizzle.h"
#import "JumpMarkList.h"
#import <objc/runtime.h>

@implementation IDEWorkspaceDocument (JumpMarks)

+ (void)load {
	NSError *error;
	[IDEWorkspaceDocument jr_swizzleMethod:@selector(_setWorkspace:)
								withMethod:@selector(jumpmarks__setWorkspace:)
									 error:&error];
}

- (void)jumpmarks__setWorkspace:(IDEWorkspace*)workspace {
	NSString* customPathString = workspace.customDataStore.customDataPath.pathString;
	if (customPathString) {
        workspace.jumpMarks = [[JumpMarkList alloc] initWithCustomDataPath:customPathString];
	}
	return [self jumpmarks__setWorkspace:workspace];
}

@end

@implementation IDEWorkspace (JumpMarks)

static char defaultHashKey;

- (void)setJumpMarks:(JumpMarkList *)jumpMarks {
    objc_setAssociatedObject(self, &defaultHashKey, jumpMarks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JumpMarkList*)jumpMarks {
    return objc_getAssociatedObject(self, &defaultHashKey) ;
}

@end