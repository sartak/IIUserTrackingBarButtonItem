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
    _normalView.frame = CGRectMake(0, 0, 32, 32);
    _normalView.userInteractionEnabled = NO;
    if (self.trackingMode == MKUserTrackingModeNone) {
        [self switchToView:_normalView animated:YES];
    }
}

-(void) setFollowView:(UIView *)followView {
    _followView = followView;
    _followView.frame = CGRectMake(0, 0, 32, 32);
    _followView.userInteractionEnabled = NO;
    if (self.trackingMode == MKUserTrackingModeFollow) {
        [self switchToView:_followView animated:YES];
    }
}

-(void) setHeadingView:(UIView *)headingView {
    _headingView = headingView;
    _headingView.frame = CGRectMake(0, 0, 32, 32);
    _headingView.userInteractionEnabled = NO;
    if (self.trackingMode == MKUserTrackingModeFollowWithHeading) {
        [self switchToView:_headingView animated:YES];
    }
}

-(void) switchToView:(UIView *)newView animated:(BOOL)animated {
    NSArray *oldSubviews = self.subviews;

    if (animated) {
        CGRect smallFrame = CGRectMake(16, 16, 0, 0);
        CGRect bigFrame = CGRectMake(0, 0, 32, 32);
        newView.frame = smallFrame;
        
        [self addSubview:newView];

        [UIView animateWithDuration:0.75f
                         animations:^{
                             newView.frame = bigFrame;
                             for (UIView *subview in oldSubviews) {
                                 subview.frame = smallFrame;
                             }
                         } completion:^(BOOL finished) {
                             for (UIView *subview in oldSubviews) {
                                 [subview removeFromSuperview];
                                 subview.frame = bigFrame;
                             }

                             // rapid tapping can end up with all the subviews removed
                             if ([self.subviews count] == 0) {
                                 [self switchToMode:self.trackingMode animated:NO];
                             }
                         }];
    }
    else {
        for (UIView *subview in oldSubviews) {
            [subview removeFromSuperview];
        }

        [self addSubview:newView];
    }
}

-(void) switchToMode:(MKUserTrackingMode)newMode animated:(BOOL)animated {
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

    [self switchToView:newView animated:animated];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    MKUserTrackingMode trackingMode = [change[@"new"] intValue];
    [self switchToMode:trackingMode animated:NO];
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
    [self switchToMode:newMode animated:YES];
}

-(void) dealloc {
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
}

@end
