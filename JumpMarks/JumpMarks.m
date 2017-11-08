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
#import "IDEWorkspaceDocument+JumpMarks.h"

#define NUM_MARKS 7

static JumpMarks *sharedPlugin;

@interface JumpMarks()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic) NSInteger lastMarkNumber;

@end

@implementation JumpMarks

#pragma mark - Lifecycle functions

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]
        || [[currentApplicationName lowercaseString] hasPrefix:@"xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin {
	if (self = [super init]) {
		self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    [self buildMenuItems];
}

- (void)buildMenuItems {
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Editor"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *jumpMarks = [[menuItem submenu] addItemWithTitle:@"JumpMarks" action:nil keyEquivalent:@""];
        NSMenu *submenu = [[NSMenu alloc] init];
        jumpMarks.submenu = submenu;
        
        // General shortcuts
        NSMenuItem *clearMarks = [submenu addItemWithTitle:@"Clear all" action:@selector(clearMarks:) keyEquivalent:@"C"];
		[clearMarks setKeyEquivalentModifierMask:NSAlternateKeyMask];
        clearMarks.target = self;
        
        NSMenuItem *prevMark = [submenu addItemWithTitle:@"Jump To Previous" action:@selector(jumpToPrevMark:) keyEquivalent:@"["];
        [prevMark setKeyEquivalentModifierMask:NSAlternateKeyMask];
        prevMark.target = self;
        
        NSMenuItem *nextMark = [submenu addItemWithTitle:@"Jump To Next" action:@selector(jumpToNextMark:) keyEquivalent:@"]"];
        [nextMark setKeyEquivalentModifierMask:NSAlternateKeyMask];
        nextMark.target = self;
        
        [submenu addItem:[NSMenuItem separatorItem]];

        // Toggle mark shortcuts
        for(int i=0; i<NUM_MARKS; i++) {
            NSMenuItem *toggleMark = [submenu addItemWithTitle:[NSString stringWithFormat:@"Place #%d", i]
                                                        action:@selector(toggleMark:) keyEquivalent:[NSString stringWithFormat:@"%d", i]];
            [toggleMark setKeyEquivalentModifierMask:NSAlternateKeyMask | NSShiftKeyMask];
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
	[[self currentJumpMarks] removeAllMarks];
// TODO: refresh all active editors on screen (not just current one for split editors)
	[[[self getCurrentSourceCodeEditor] valueForKey:@"_sidebarView"] setNeedsDisplay:YES];
}

- (void)jumpToPrevMark:(NSMenuItem*)sender {
	NSNumber *markNumber = [[self currentJumpMarks] getPrevMarkNumber:_lastMarkNumber];
	if (markNumber) {
		[self jumpToMarkNumber:[markNumber integerValue]];
	}
}

- (void)jumpToNextMark:(NSMenuItem*)sender {
	NSNumber *markNumber = [[self currentJumpMarks] getNextMarkNumber:_lastMarkNumber];
	if (markNumber) {
		[self jumpToMarkNumber:[markNumber integerValue]];
	}
}

- (void)jumpToMark:(NSMenuItem*)sender {
    NSNumber *markNumber = sender.representedObject;
	[self jumpToMarkNumber:[markNumber integerValue]];
}

- (BOOL)jumpToMarkNumber:(NSInteger)markNumber {
    JumpMark* mark = [[self currentJumpMarks] getMarkNumber:markNumber];

	if(mark) {
		NSString *currentPath = [self getCurrentSourceCodeEditor].sourceCodeDocument.fileURL.path;
		if(![mark.filePath isEqualToString:currentPath]){
			[self jumpToFileURL:[NSURL fileURLWithPath:mark.filePath]];
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
		_lastMarkNumber = markNumber;
		return YES;
	}
	return NO;
}

- (void)jumpToFileURL:(NSURL *)fileURL {
	DVTDocumentLocation *documentLocation = [[DVTDocumentLocation alloc] initWithDocumentURL:fileURL timestamp:nil];
	IDEEditorOpenSpecifier *openSpecifier = [IDEEditorOpenSpecifier structureEditorOpenSpecifierForDocumentLocation:documentLocation
																										inWorkspace:[self currentIDEWorkspace]
																											  error:nil];
	[[self currentIDEWorkspaceWindowController].editorArea.lastActiveEditorContext openEditorOpenSpecifier:openSpecifier];
}

- (void)toggleMark:(NSMenuItem*)sender {
    NSInteger markNumber = [sender.representedObject integerValue];
	
    IDESourceCodeEditor *editor = [self getCurrentSourceCodeEditor];
    // Ignore comparison editors
    if (editor) {
        DVTSourceTextView* textView = editor.textView;
        IDESourceCodeDocument *sourceCodeDocument = editor.sourceCodeDocument;
        [[self currentJumpMarks] toggleMarkNumber:markNumber
                                               filePath:sourceCodeDocument.fileURL.path
                                             lineNumber:[self currentLineNumberWithTextView:textView]];
		[[editor valueForKey:@"_sidebarView"] setNeedsDisplay:YES];
		_lastMarkNumber = markNumber;
        [[self currentJumpMarks] flush];
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

// Returns the jumpmarks for the workspace associated with the current document open
// if there are projects projects open
- (JumpMarkList*)currentJumpMarks {
    return [self currentIDEWorkspace].jumpMarks;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
