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
		[[JumpMarkList sharedInstance] setCustomDataPath:customPathString];
		[[JumpMarkList sharedInstance] load];
	}
	return [self jumpmarks__setWorkspace:workspace];
}

@end