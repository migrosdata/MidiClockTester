//
//  MCTAppDelegate.m
//  MidiClockTester
//
//  Created by avf on 20.07.13.
//  Copyright (c) 2013 oub. All rights reserved.
//

#import "MCTAppDelegate.h"

@implementation MCTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    mr = [[MidiReceiver alloc] init];
    mr.mctAppDelegate = self;
    [mr listSources];
}

- (void) updateAverage:(NSString *)value {
    [self.average setStringValue:value];
}

- (void) updateDeviation:(NSString *)value {
    [self.deviation setStringValue:value];
}

- (void) updateTempo:(NSString *)value {
    [self.tempo setStringValue:value];
}

- (void) updateMin:(double)minValue andMax:(double)maxValue {
    [self.minInterval setDoubleValue:minValue];
    [self.maxInterval setDoubleValue:maxValue];
}
@end
