//
//  DDAnnotation.m
//  MapKitDragAndDrop
//
//  Created by digdog on 7/24/09.
//  Copyright 2009  software.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//   
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//   
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import "DDAnnotation.h"

#pragma mark -
#pragma mark DDAnnotation implementation

@implementation DDAnnotation

@synthesize coordinate = _coordinate; // property declared in MKAnnotation.h
@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate title:(NSString*)newTitle {

	if ((self = [super init])) {
		[self changeCoordinate:newCoordinate];
		_title = [newTitle retain];
	}
	return self;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	
	if (_title) {
		[_title release];
		_title = nil;		
	}
	
	if (_subtitle) {
		[_subtitle release];
		_subtitle = nil;		
	}
	
	[super dealloc];
}

#pragma mark -
#pragma mark Override MKAnnotation Method

- (NSString *)subtitle {
	if (_subtitle) {
		return _subtitle; 
	} 
	
	return _subtitle;
	
	/*return [NSString stringWithFormat:@"%.4f° %@, %.4f° %@", 
			fabs(_coordinate.latitude), signbit(_coordinate.latitude) ? @"South" : @"North", 
			fabs(_coordinate.longitude), signbit(_coordinate.longitude) ? @"West" : @"East"];*/
}

#pragma mark -
#pragma mark Change coordinate

- (void)changeCoordinate:(CLLocationCoordinate2D)newCoordinate {
	_coordinate = newCoordinate;

	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"DDAnnotationCoordinateDidChangeNotification" object:self]];		
}

@end
