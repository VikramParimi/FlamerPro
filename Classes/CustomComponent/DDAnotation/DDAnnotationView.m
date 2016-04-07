//
//  DDAnnotationView.m
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

#import "DDAnnotationView.h"
#import "DDAnnotation.h"

#pragma mark -
#pragma mark DDAnnotationView implementation

@implementation DDAnnotationView

@synthesize mapView = _mapView;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		self.enabled = YES;
		self.canShowCallout = YES;
		self.multipleTouchEnabled = NO;
		self.animatesDrop = YES;		
	}
	return self;
}

#pragma mark -
#pragma mark Handling events

// Reference: iPhone Application Programming Guide > Device Support > Displaying Maps and Annotations > Displaying Annotations > Handling Events in an Annotation View

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// The view is configured for single touches only.
    UITouch* aTouch = [touches anyObject];
    _startLocation = [aTouch locationInView:[self superview]];
    _originalCenter = self.center;
	
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch* aTouch = [touches anyObject];
    CGPoint newLocation = [aTouch locationInView:[self superview]];
    CGPoint newCenter;
	
	// If the user's finger moved more than 5 pixels, begin the drag.
    if ((abs(newLocation.x - _startLocation.x) > 5.0) || (abs(newLocation.y - _startLocation.y) > 5.0)) {
		_isMoving = YES;		
	}
	
	// If dragging has begun, adjust the position of the view.
    if (_mapView && _isMoving) {
        newCenter.x = _originalCenter.x + (newLocation.x - _startLocation.x);
        newCenter.y = _originalCenter.y + (newLocation.y - _startLocation.y);
        self.center = newCenter;
    } else {
		// Let the parent class handle it.
        [super touchesMoved:touches withEvent:event];		
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if (_mapView && _isMoving) {				
        // Update the map coordinate to reflect the new position.
        CGPoint newCenter = self.center;
        DDAnnotation* theAnnotation = (DDAnnotation *)self.annotation;
        CLLocationCoordinate2D newCoordinate = [_mapView convertPoint:newCenter toCoordinateFromView:self.superview];
		
        [theAnnotation changeCoordinate:newCoordinate];
		
        // Clean up the state information.
        _startLocation = CGPointZero;
        _originalCenter = CGPointZero;
        _isMoving = NO;		
	} else {
        [super touchesEnded:touches withEvent:event];		
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    if (_mapView && _isMoving) {
        // Move the view back to its starting point.
        self.center = _originalCenter;
		
        // Clean up the state information.
        _startLocation = CGPointZero;
        _originalCenter = CGPointZero;
        _isMoving = NO;
    } else {
        [super touchesCancelled:touches withEvent:event];		
	}
}

@end
