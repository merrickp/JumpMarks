//
//  JumpMarks.m
//  JumpMarks
//
//  Created by Merrick Poon on 3/22/15.
//  Copyright (c) 2015 Merrick Poon. All rights reserved.
//

#import "JumpMarks.h"
#import "IDEKit.h"
#import "IDESourceEditor.h"
#import "JumpMarkList.h"

static JumpMarks *sharedPlugin;

#define NUM_MARKS 10

@interface JumpMarks()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation JumpMarks

#pragma mark - Lifecycle functions

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        self.bundle = plugin;

        [self buildMenuItems];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildMenuItems {
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"View"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *jumpMarks = [[menuItem submenu] addItemWithTitle:@"JumpMarks" action:nil keyEquivalent:@""];
        NSMenu *submenu = [[NSMenu alloc] init];
        jumpMarks.submenu = submenu;
        
        // General shortcuts
        NSMenuItem *clearMarks = [submenu addItemWithTitle:@"Clear all Marks" action:@selector(clearMarks:) keyEquivalent:@""];
        clearMarks.target = self;
        
        NSMenuItem *prevMark = [submenu addItemWithTitle:@"Jump To Prev Mark" action:@selector(jumpToPrevMark:) keyEquivalent:@"["];
        [prevMark setKeyEquivalentModifierMask: NSAlternateKeyMask];
        prevMark.target = self;
        
        NSMenuItem *nextMark = [submenu addItemWithTitle:@"Jump To Next Mark" action:@selector(jumpToNextMark:) keyEquivalent:@"]"];
        [nextMark setKeyEquivalentModifierMask: NSAlternateKeyMask];
        nextMark.target = self;
        
        [submenu addItem:[NSMenuItem separatorItem]];

        // Toggle mark shortcuts
        for(int i=0; i<NUM_MARKS; i++) {
            NSMenuItem *toggleMark = [submenu addItemWithTitle:[NSString stringWithFormat:@"Toggle #%d", i]
                                                        action:@selector(toggleMark:) keyEquivalent:[NSString stringWithFormat:@"%d", i]];
            [toggleMark setKeyEquivalentModifierMask: NSAlternateKeyMask | NSShiftKeyMask];
            [toggleMark setRepresentedObject:@(i)];
            toggleMark.target = self;
        }

        [submenu addItem:[NSMenuItem separatorItem]];

        // Jump to mark shortcuts
        for(int i=0; i<NUM_MARKS; i++) {
            NSMenuItem *jumpToMark = [submenu addItemWithTitle:[NSString stringWithFormat:@"Jump To #%d", i]
                                                        action:@selector(jumpToMark:) keyEquivalent:[NSString stringWithFormat:@"%d", i]];
            [jumpToMark setKeyEquivalentModifierMask: NSAlternateKeyMask];
            [jumpToMark setRepresentedObject:@(i)];
            jumpToMark.target = self;
        }
    }
}

#pragma mark - Menu item hooks

- (void)clearMarks:(NSMenuItem*)sender {
    
}

- (void)jumpToPrevMark:(NSMenuItem*)sender {
    
}

- (void)jumpToNextMark:(NSMenuItem*)sender {
    
}

- (void)jumpToMark:(NSMenuItem*)sender {
    NSNumber *markNumber = sender.representedObject;
    JumpMark* mark = [[JumpMarkList sharedInstance] getMarkNumber:[markNumber integerValue]];

    if(mark) {
        NSString *currentPath = [self getCurrentSourceCodeEditor].sourceCodeDocument.fileURL.path;
        if(![mark.filePath isEqualToString:currentPath]){
            IDEDocumentController* ctrl = [IDEDocumentController sharedDocumentController];
            NSError* error;
            NSURL* doc = [NSURL fileURLWithPath:mark.filePath];
            [ctrl openDocumentWithContentsOfURL:doc display:YES error:&error];
        }
    }

    IDESourceCodeEditor *editor = [self getCurrentSourceCodeEditor];
    // Ignore comparison editors
    if (editor) {
        DVTSourceTextView* textView = editor.textView;
        
        NSUInteger lineNumber = mark.lineNumber;
        NSUInteger lineLocation = [self locationRangeForTextView:textView forLine:lineNumber-1];
        NSRange locationRange = NSMakeRange(lineLocation, 0);
        
        [textView setSelectedRange:locationRange];
        [textView scrollRangeToVisible:locationRange];
        [textView showFindIndicatorForRange:locationRange];
    }
}

- (void)toggleMark:(NSMenuItem*)sender {
    NSInteger markNumber = [sender.representedObject integerValue];
    
    IDESourceCodeEditor *editor = [self getCurrentSourceCodeEditor];
    // Ignore comparison editors
    if (editor) {
        DVTSourceTextView* textView = editor.textView;
        IDESourceCodeDocument *sourceCodeDocument = editor.sourceCodeDocument;
        [[JumpMarkList sharedInstance] toggleMarkNumber:markNumber
                                               filePath:sourceCodeDocument.fileURL.path
                                             lineNumber:[self currentLineNumberWithTextView:textView]];
        [[JumpMarkList sharedInstance] flush];
    }
}

#pragma mark - IDE helper functions

- (IDESourceCodeEditor*)getCurrentSourceCodeEditor {
    IDEEditorArea *editorArea = [[self currentIDEWorkspaceWindowController] editorArea];
    IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
    IDEEditor *editor = editorContext.editor;
    if([editor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return (IDESourceCodeEditor*)editor;
    }
    return nil;
}

- (IDEWorkspace*)currentIDEWorkspace {
    return (IDEWorkspace*) [[self currentIDEWorkspaceWindowController] valueForKey:@"_workspace"];
}

- (IDEWorkspaceWindowController*)currentIDEWorkspaceWindowController {
    NSWindowController *mainWindowController = [[NSApp mainWindow] windowController];
    return (IDEWorkspaceWindowController *)mainWindowController;
}

- (NSUInteger)currentLineNumberWithTextView:(DVTSourceTextView*)textView {
    DVTTextStorage *textStorage = (DVTTextStorage*)textView.textStorage;
    
    NSUInteger lineIndex = [textStorage lineRangeForCharacterRange:
                            NSMakeRange(textView.selectedRange.location, 0)].location;
    
    // Return 1-based index
    return lineIndex + 1;
}
- (NSUInteger)locationRangeForTextView:(DVTSourceTextView*)textView forLine:(NSUInteger)lineNumber {
    DVTTextStorage *textStorage = (DVTTextStorage*)textView.textStorage;
    
    NSRange characterRange = [textStorage characterRangeForLineRange:NSMakeRange(lineNumber, 0)];
    
    return characterRange.location; 
}

@end
