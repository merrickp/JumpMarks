//
//  DVTTextSidebarView+JumpMarks.h
//  JumpMarks
//
//  Created by Merrick Poon on 3/22/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVTTextSidebarView.h"

@interface DVTTextSidebarView (JumpMarks)

- (void)jumpmarks_drawLineNumbersInSidebarRect:(CGRect)rect
                                 foldedIndexes:(NSUInteger *)indexes
                                         count:(NSUInteger)indexCount
                                 linesToInvert:(id)invert
                              linesToHighlight:(id)highlight
                                linesToReplace:(id)replace
                                      textView:(id)textView
                              getParaRectBlock:(GetParaBlock)rectBlock;

@end
