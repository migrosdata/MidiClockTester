//
//  MidiReceiver.h
//  MidiClockTester
//
//  Created by avf on 20.07.13.
//  Copyright (c) 2013 oub. All rights reserved.
//
#include <stdint.h>
#include <mach/mach_time.h>
#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

//#import "MCTAppDelegate.h"
@class MCTAppDelegate;

#define AVG_N 200

@interface MidiReceiver : NSObject {
    uint64_t prev;
    uint64_t sum;
    double avg;
    int nbr;
    double minTime;
    double maxTime;
	uint64_t intervals[ AVG_N + 1 ];
}
@property (assign) MIDIClientRef client;
@property (assign) MIDIPortRef inPort;

@property (assign) MIDIEndpointRef iac;

@property (weak) MCTAppDelegate *mctAppDelegate;

- (NSArray *) listSources;


@end
