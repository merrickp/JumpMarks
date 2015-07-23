//
//  JumpMarksTest.m
//  JumpMarksTest
//
//  Created by Merrick Poon on 7/20/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JumpMark.h"
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

static NSString *const JUMPMARKS_PATH = @"Library/Application Support/Developer/Shared/Xcode/Plug-ins/JumpMarks.xcplugin";

SpecBegin(JumpMarksTests)

//NSBundle *pluginBundle = [NSBundle bundleWithPath:[NSHomeDirectory() stringByAppendingPathComponent:JUMPMARKS_PATH]];

SpecEnd
