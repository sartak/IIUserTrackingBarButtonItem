#import "IIUserTrackingBarButtonItem.h"

@implementation IIUserTrackingBarButtonItem

-(id) initWithMapView:(MKMapView *)mapView normalView:(UIView *)normalView followView:(UIView *)followView headingView:(UIView *)headingView {    
    self = [self initWithCustomView:[self parentView]];
    if (self) {
        self.normalView = normalView;
        self.followView = followView;
        self.headingView = headingView;

        self.normalView.frame = CGRectMake(0, 0, 40, 40);
        self.followView.frame = CGRectMake(0, 0, 40, 40);
        self.headingView.frame = CGRectMake(0, 0, 40, 40);

        // assign mapView last since it fires off KVO immediately
        self.mapView = mapView;

    }
    return self;
}

-(UIGestureRecognizer *)switchModeRecognizer {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode)];
    return recognizer;
}

-(UIView *)parentView {
    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [parentView addGestureRecognizer:[self switchModeRecognizer]];
    return parentView;
}

-(void) setMapView:(MKMapView *)mapView {
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
    _mapView = mapView;
    [mapView addObserver:self forKeyPath:@"userTrackingMode" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    MKUserTrackingMode trackingMode = [change[@"new"] intValue];
    UIView *newView;

    switch (trackingMode) {
        default:
        case MKUserTrackingModeNone:
            newView = self.normalView;
            break;
        case MKUserTrackingModeFollow:
            newView = self.followView;
            break;
        case MKUserTrackingModeFollowWithHeading:
            newView = self.headingView;
            break;
    }

    for (UIView *subview in self.customView.subviews) {
        [subview removeFromSuperview];
    }

    [self.customView addSubview:newView];
}

-(void) switchMode {
    MKUserTrackingMode trackingMode = self.mapView.userTrackingMode;
    MKUserTrackingMode newMode;
    
    switch (trackingMode) {
        default:
        case MKUserTrackingModeNone:
            newMode = MKUserTrackingModeFollow;
            break;
        case MKUserTrackingModeFollow:
            newMode = MKUserTrackingModeFollowWithHeading;
            break;
        case MKUserTrackingModeFollowWithHeading:
            newMode = MKUserTrackingModeNone;
            break;
    }

    [self.mapView setUserTrackingMode:newMode];
}

-(void) dealloc {
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
}

@end
