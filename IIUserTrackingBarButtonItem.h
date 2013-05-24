#import <MapKit/MapKit.h>

@interface IIUserTrackingBarButtonItem : UIBarButtonItem

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIView *normalView;
@property (nonatomic, strong) UIView *followView;
@property (nonatomic, strong) UIView *headingView;

-(id) initWithMapView:(MKMapView *)mapView normalView:(UIView *)normalView followView:(UIView *)followView headingView:(UIView *)headingView;

@end
