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
		
        self->maxTime = 0;
        self->minTime = DBL_MAX;
		self->prev = 0;
		self->nbr = 0;

		MIDIPortRef inPort;
		MIDIInputPortCreate(client, CFSTR("Input"), myReadProc, (__bridge_retained void *)(self), &inPort);
		self.inPort = inPort;
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
        //printPacketInfo(packet);
		
		for( int j = 0; j < packet->length; j++ )
		{
			if( packet->data[ j ] == 0xf8 )
			{
		        [myDocument storeTimeStamp:packet->timeStamp];
			}
		}
		
        packet = MIDIPacketNext(packet);
    }
    
	@autoreleasepool {
    	[myDocument.mctAppDelegate updateAverage:[NSString stringWithFormat:@"%lf", myDocument->avg]];
	    double tempo = (1000 / myDocument->avg / 24) * 60;
	    [myDocument.mctAppDelegate updateTempo:[NSString stringWithFormat:@"%lf", tempo]];
	    [myDocument.mctAppDelegate updateMin:myDocument->minTime andMax:myDocument->maxTime];
    
	    //double deviation = sqrt(pow(myDocument->sum - myDocument->avg, 2) / (myDocument->nbr -1));
	    //[myDocument.mctAppDelegate updateDeviation:[NSString stringWithFormat:@"%lf", deviation]];
	}
}

-(void) storeTimeStamp:(uint64_t) time{
    //double timeInSec = convertTimeInMilliseconds(time);
    if (self->prev == 0){
        self->prev = time;
        self->nbr = 0;
        self->avg = 0;
    } else {
        uint64_t interval = time - self->prev;
        self->prev = time;
		//double intervalInSec = convertTimeInMilliseconds( interval );
		//NSLog( @"%lld", interval );
        //self->sum += interval;

        self->nbr++;
		self->intervals[ self->nbr ] = interval;

		if( self->nbr >= AVG_N )
		{
			self->sum = 0;

			for( int i = 1; i <= AVG_N; i++ )
			{
				self->sum += self->intervals[ i ];
			}

			self->avg = convertTimeInMilliseconds( self->sum / AVG_N );
			double ssd = 0.0;

			for( int i = 1; i <= AVG_N; i++ )
			{
				
				double diff = convertTimeInMilliseconds( self->intervals[ i ] ) - self->avg;
				ssd += diff * diff;
			}

			self->nbr = 0;
			self->minTime = sqrt( ssd / AVG_N );
		}
		
        /*
		self->avg = convertTimeInMilliseconds( sum / nbr );
        self->prev = time;
        //self->minTime = MIN(self->minTime, interval);
        if (intervalInSec < self->minTime) {
            self->minTime = intervalInSec;
        }
        if (intervalInSec > self->maxTime) {
            self->maxTime = intervalInSec;
        }
		*/
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
