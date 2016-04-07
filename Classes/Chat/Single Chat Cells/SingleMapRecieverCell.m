//
//  SingleMapRecieverCell.m
//  snapchatclone
//
//  Created by soumya ranjan sahu on 17/12/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "SingleMapRecieverCell.h"

@implementation SingleMapRecieverCell

- (void)awakeFromNib
{
    // Initialization code
    [self.userImageView.layer setCornerRadius:22];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Map Methods -

-(void)showmap_lat:(double)lat lng:(double)lng title:(NSString *)title
{
    MKCoordinateRegion region;
    region.center.latitude = lat;
    region.center.longitude = lng;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.5;
    span.longitudeDelta = 0.5;
    region.span = span;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = lat;
    coordinate.longitude = lng;
    DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:coordinate title:title];
    
    [self.mapView addAnnotation:annotation];
    [self.mapView setRegion:region];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString * const kPinAnnotationIdentifier = @"AnnotationIdentifier";
    
    MKAnnotationView *mapAnnotation = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
    mapAnnotation.canShowCallout = YES;
    
    if ([annotation.title isEqualToString:@"Current Location"]) {
        
        return nil;
    }
    else{
        [mapAnnotation setImage:[UIImage imageNamed:@"Pin.png"]];
        
        //        mapAnnotation= [mapView  dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
        //         mapAnnotation = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
        //        mapAnnotation.canShowCallout = YES;
        //        [mapAnnotation setImage:[UIImage imageNamed:@"mapAnnotImg.png"]];
        return mapAnnotation;
    }
}

@end
