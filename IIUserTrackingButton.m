#import "IIUserTrackingButton.h"

@interface IIUserTrackingButton ()

@property (nonatomic, readonly) MKUserTrackingMode trackingMode;

@end

@implementation IIUserTrackingButton

-(id) initWithMapView:(MKMapView *)mapView normalView:(UIView *)normalView followView:(UIView *)followView headingView:(UIView *)headingView {
    self = [self init];

    if (self) {
        [self addTarget:self action:@selector(mapSwitchedMode) forControlEvents:UIControlEventTouchUpInside];

        self.normalView = normalView;
        self.followView = followView;
        self.headingView = headingView;

        // assign mapView last since it fires off KVO immediately
        self.mapView = mapView;
    }
    return self;
}

-(MKUserTrackingMode) trackingMode {
    return self.mapView.userTrackingMode;
}

-(void) setMapView:(MKMapView *)mapView {
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
    _mapView = mapView;
    [mapView addObserver:self forKeyPath:@"userTrackingMode" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
}

-(void) setNormalView:(UIView *)normalView {
    _normalView = normalView;
    _normalView.frame = CGRectMake(0, 0, 40, 40);
    _normalView.userInteractionEnabled = NO;
    if (self.trackingMode == MKUserTrackingModeNone) {
        [self switchToView:_normalView];
    }
}

-(void) setFollowView:(UIView *)followView {
    _followView = followView;
    _followView.frame = CGRectMake(0, 0, 40, 40);
    _followView.userInteractionEnabled = NO;
    if (self.trackingMode == MKUserTrackingModeFollow) {
        [self switchToView:_followView];
    }
}

-(void) setHeadingView:(UIView *)headingView {
    _headingView = headingView;
    _headingView.frame = CGRectMake(0, 0, 40, 40);
    _headingView.userInteractionEnabled = NO;
    if (self.trackingMode == MKUserTrackingModeFollowWithHeading) {
        [self switchToView:_headingView];
    }
}

-(void) switchToView:(UIView *)newView {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }

    [self addSubview:newView];
}

-(void) switchToMode:(MKUserTrackingMode)newMode {
    UIView *newView;

    switch (newMode) {
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

    [self switchToView:newView];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    MKUserTrackingMode trackingMode = [change[@"new"] intValue];
    [self switchToMode:trackingMode];
}

-(void) mapSwitchedMode {
    MKUserTrackingMode trackingMode = self.trackingMode;
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

    [self.mapView setUserTrackingMode:newMode animated:YES];

    // setUserTrackingMode:animated: doesn't seem to fire KVO, so we have to manually switch views
    [self switchToMode:newMode];
}

-(void) dealloc {
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
}

@end
