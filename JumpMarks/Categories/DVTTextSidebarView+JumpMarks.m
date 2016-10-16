//
//  DVTTextSidebarView+JumpMarks.m
//  JumpMarks
//
//  Created by Merrick Poon on 3/22/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import "DVTTextSidebarView+JumpMarks.h"
#import "JRSwizzle.h"
#import "JumpMarkList.h"
#import "IDEKit.h"
#import "IDEWorkspaceDocument+JumpMarks.h"

@implementation DVTTextSidebarView (JumpMarks)

+ (void)load {
    NSError *error = nil;

    [DVTTextSidebarView jr_swizzleMethod:@selector(_drawLineNumbersInSidebarRect:foldedIndexes:count:linesToInvert:linesToHighlight:linesToReplace:textView:getParaRectBlock:)
                              withMethod:@selector(jumpmarks_drawLineNumbersInSidebarRect:foldedIndexes:count:linesToInvert:linesToHighlight:linesToReplace:textView:getParaRectBlock:)
                                   error:&error];
}

- (void)jumpmarks_drawLineNumbersInSidebarRect:(CGRect)rect
                                 foldedIndexes:(NSUInteger *)indexes
                                         count:(NSUInteger)indexCount
                                 linesToInvert:(id)invert
                              linesToHighlight:(id)highlight
                                linesToReplace:(id)replace
                                      textView:(id)textView
                              getParaRectBlock:(GetParaBlock)rectBlock {
    NSArray *fileMarks = nil;
	if([self.window.delegate isKindOfClass:IDEWorkspaceWindowController.class]) {
		IDEWorkspaceWindowController *controller = (IDEWorkspaceWindowController*)self.window.delegate;
		IDEWorkspace *workspace = [controller valueForKey:@"_workspace"];
		fileMarks = [workspace.jumpMarks marksForFilePath:[[self window] representedFilename]];
	}

    if([fileMarks count]) {
        NSSortDescriptor *lineNumberSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineNumber" ascending:YES];
        NSArray<__kindof JumpMark*> *lineMarksAscending = [fileMarks sortedArrayUsingDescriptors:@[lineNumberSortDescriptor]];
        NSEnumerator<__kindof JumpMark*> *markEnumerator = [lineMarksAscending objectEnumerator];
        JumpMark *nextMark = [markEnumerator nextObject];
        
        for (NSUInteger i=0; i<indexCount && nextMark != nil; i++) {
            NSUInteger line = indexes[i];
            if (nextMark.lineNumber == line) {
                [self drawMarkAtLineNumber:line withMarkNumber:nextMark.markNumber];
            }
            while(nextMark && line >= nextMark.lineNumber) {
                nextMark = [markEnumerator nextObject];
            }
        }
    }
    
    [self jumpmarks_drawLineNumbersInSidebarRect:rect foldedIndexes:indexes count:indexCount
                                   linesToInvert:invert linesToHighlight:highlight linesToReplace:replace
                                        textView:textView getParaRectBlock:rectBlock];
}

- (void)drawMarkAtLineNumber:(NSInteger)lineNumber withMarkNumber:(NSInteger)markNumber {
    CGRect a0, a1;
    [self getParagraphRect:&a0 firstLineRect:&a1 forLineNumber:lineNumber];
    a1.size = NSMakeSize(a1.size.height, a1.size.height);

    [[NSColor colorWithCalibratedRed:7/255.0f green:125/255.0f blue:0.0f alpha:1.0f] setFill];
    [[NSBezierPath bezierPathWithOvalInRect:a1] fill];

    NSMutableParagraphStyle *centeredParagraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    centeredParagraph.alignment = NSCenterTextAlignment;
    
    NSFont *font = self.lineNumberFont;
    NSDictionary *textAttributes =
    @{NSFontAttributeName: font,
      NSForegroundColorAttributeName: [NSColor colorWithCalibratedRed:165/255.0f green:205/255.0f blue:23/255.0f alpha:1.0f],
      NSParagraphStyleAttributeName: centeredParagraph
      };
    NSString *jumpText = [NSString stringWithFormat:@"%ld", markNumber];
//    CGRect labelRect = [jumpText boundingRectWithSize:a1.size options:0 attributes:nil];

    [jumpText drawInRect:a1 withAttributes:textAttributes];
}

@end
