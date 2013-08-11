//
//  GBSHelpBookPaletteViewController.m
//  HelpBook
//
//  Created by Brent Royal-Gordon on 8/9/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "GBSHelpBookPaletteViewController.h"
#import "GBSHelpBookPlugin.h"
#import "GBSHelpBookWriter.h"

@dynamic_implementation(VPUPaletteViewController)

@interface GBSHelpBookPaletteViewController ()

@end

@implementation GBSHelpBookPaletteViewController

+ (id)makeContentViewController {
    return [[self alloc] initWithNibName:@"GBSHelpBookPaletteViewController" bundle:[NSBundle bundleWithIdentifier:@"com.groundbreakingsoftware.voodoopad.HelpBook"]];
}

+ (NSString *)displayName {
    return NSLocalizedString(@"Help Book", @"");
}

- (NSString *)displayName {
    return NSLocalizedString(@"Help Book", @"");
}

- (id<VPPluginDocument>)currentDocument {
    id <VPPluginDocument>doc = [[NSDocumentController sharedDocumentController] currentDocument];
    
    if (!doc && [[[NSDocumentController sharedDocumentController] documents] count]) {
        // wtf, appkit is holding out on us.
        doc = [[[NSDocumentController sharedDocumentController] documents] objectAtIndex:0];
        
        // sanity check.
        if (![(id)doc respondsToSelector:@selector(orderedPageKeysByCreateDate)]) {
            doc = nil;
        }
    }
    
    return doc;
}

- (void)export:(id)sender {
    NSSavePanel * panel = [NSSavePanel savePanel];
    panel.allowedFileTypes = @[ @"help" ];
    
    NSURL * outputURL = [GBSHelpBookPlugin outputURLForDocument:self.currentDocument];
    if(outputURL) {
        panel.directoryURL = outputURL.URLByDeletingLastPathComponent;
        panel.nameFieldStringValue = outputURL.lastPathComponent;
    }
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if(!result) {
            return;
        }
        
        [GBSHelpBookPlugin setOutputURL:panel.URL forDocument:self.currentDocument];
        
        GBSHelpBookWriter * writer = [GBSHelpBookWriter new];
        
        writer.document = self.currentDocument;
        
        writer.bundleIdentifier = @"com.groundbreakingsoftware.typesetter.help";
        writer.bundleName = @"Typesetter";
        writer.helpBookTitle = @"Typesetter Help";
        writer.locale = @"en";
        
        NSError * error;
        
        if(![writer writeToURL:panel.URL error:&error]) {
            [self presentError:error];
        }
        
        [self documentDidChange];
    }];
}

- (void)documentDidChange {
//    [super documentDidChange];
    
    self.hasDocument = (self.currentDocument != nil);
    
    NSURL * outputURL = [GBSHelpBookPlugin outputURLForDocument:self.currentDocument];
    self.exportFileString = outputURL.path;
    
    self.canExport = YES;
}

- (void)chooseOutputFile:(id)sender {
    if (!self.currentDocument) {
        return;
    }
    
}

@end
