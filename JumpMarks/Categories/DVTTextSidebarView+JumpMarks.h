//
//  DVTTextSidebarView+JumpMarks.h
//  JumpMarks
//
//  Created by Merrick Poon on 3/22/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVTKit.h"

@interface DVTTextSidebarView (JumpMarks)

- (void)jumpmarks_drawLineNumbersInSidebarRect:(CGRect)arg1
                                 foldedIndexes:(NSUInteger *)indexes
                                         count:(NSUInteger)indexCount
                                 linesToInvert:(id)invert
                                linesToReplace:(id)replace
                              getParaRectBlock:(id)rectBlock;

@end
