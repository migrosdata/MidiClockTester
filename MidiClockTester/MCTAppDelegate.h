//
//  MCTAppDelegate.h
//  MidiClockTester
//
//  Created by avf on 20.07.13.
//  Copyright (c) 2013 oub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MidiReceiver.h"

@interface MCTAppDelegate : NSObject <NSApplicationDelegate> {
    MidiReceiver *mr;
}
@property (weak) IBOutlet NSTextField *minInterval;
@property (weak) IBOutlet NSTextField *maxInterval;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextFieldCell *tempo;
@property (weak) IBOutlet NSTextField *deviation;
@property (weak) IBOutlet NSTextField *average;

-(void) updateAverage:(NSString*) value;
-(void) updateTempo:(NSString*) value;
-(void) updateDeviation:(NSString*) value;
-(void) updateMin:(double) minValue andMax:(double)maxValue;
@end
