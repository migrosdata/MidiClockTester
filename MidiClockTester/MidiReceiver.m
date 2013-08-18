//
//  MidiReceiver.m
//  MidiClockTester
//
//  Created by avf on 20.07.13.
//  Copyright (c) 2013 oub. All rights reserved.
//

#import "MidiReceiver.h"
#import "MCTAppDelegate.h"

@implementation MidiReceiver

- (id) init
{
	if( self = [super init] )
	{
		MIDIClientRef client;
		MIDIClientCreate(CFSTR("MCT Client"), NULL, NULL, &client );
		self.client = client;
		
		MIDIPortRef inPort;
		MIDIInputPortCreate(client, CFSTR("Input"), myReadProc, (__bridge_retained void *)(self), &inPort);
		self.inPort = inPort;
        self->maxTime = 0;
        self->minTime = DBL_MAX;
	}
	
	return self;
}

- (void) yo {

}

void myReadProc(const MIDIPacketList *packetList, void* readProcRefCon,
                void* srcConnRefCon) {
    MIDIPacket *packet = (MIDIPacket*)packetList->packet;
    MidiReceiver* myDocument = (__bridge MidiReceiver*)readProcRefCon;
    
    int i;
    int count = packetList->numPackets;
    for (i=0; i<count; i++) {
        printPacketInfo(packet);
        [myDocument storeTimeStamp:packet->timeStamp];
        packet = MIDIPacketNext(packet);
    }
    
    [myDocument.mctAppDelegate updateAverage:[NSString stringWithFormat:@"%lf", myDocument->avg]];
    double tempo = (1000 / myDocument->avg / 24) * 60;
    [myDocument.mctAppDelegate updateTempo:[NSString stringWithFormat:@"%lf", tempo]];
    [myDocument.mctAppDelegate updateMin:myDocument->minTime andMax:myDocument->maxTime];
    
    //double deviation = sqrt(pow(myDocument->sum - myDocument->avg, 2) / (myDocument->nbr -1));
    //[myDocument.mctAppDelegate updateDeviation:[NSString stringWithFormat:@"%lf", deviation]];
}

-(void) storeTimeStamp:(uint64_t) time{
    double timeInSec = convertTimeInMilliseconds(time);
    if (self->prev == 0){
        self->prev = timeInSec;
    }
    else {
        double interval = timeInSec - self->prev;
        self->sum += interval;
        self->nbr++;
        self->avg = sum / nbr;
        self->prev = timeInSec;
        //self->minTime = MIN(self->minTime, interval);
        if (interval < self->minTime) {
            self->minTime = interval;
        }
        if (interval > self->maxTime) {
            self->maxTime = interval;
        }
        //self->maxTime = MAX(self->maxTime, interval);
    }
}

void printPacketInfo(const MIDIPacket* packet) {
    double timeinsec = packet->timeStamp / (double)1e9;
    printf("%9.3lf\t", timeinsec);
    printf("%lf", convertTimeInMilliseconds(packet->timeStamp));
    int i;
    for (i=0; i<packet->length; i++) {
        if (packet->data[i] < 0x7f) {
            printf("%d ", packet->data[i]);
        } else {
            printf("0x%x ", packet->data[i]);
        }
    }
    printf("\n");
    //[self.tempo setStringValue:@"yo"];
}

double convertTimeInMilliseconds(uint64_t time)
{
    const double kOneMillion = 1000 * 1000;
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    // mach_absolute_time() returns billionth of seconds,
    // so divide by one million to get milliseconds
    return (double)((time * s_timebase_info.numer) / (kOneMillion * s_timebase_info.denom));
}


-(NSArray *) listSources {
    ItemCount sourceCount = MIDIGetNumberOfSources();
    //NSMutableArray *sources = [NSMutableArray arrayWithCapacity: sourceCount];
    
    for (ItemCount i = 0 ; i < sourceCount ; ++i) {
        // Grab a reference to a source endpoint
		MIDIEndpointRef source = MIDIGetSource(i);
        if (source) {
            NSString *name = getDisplayName(source);
			NSLog( @"%@", name );
            //if([name isEqualToString:@"LPK25"]) {
                MIDIPortConnectSource(self.inPort, source, NULL);
            //}
            //[sources addObject:source];
        }
    }
    
    return NULL;
}

NSString *getDisplayName( MIDIObjectRef object )
{
	// Returns the display name of a given MIDIObjectRef as an NSString
	CFStringRef name = nil;
	if( MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name ) != noErr )
		return nil;
    
	return (NSString *)CFBridgingRelease( name );
}

@end
