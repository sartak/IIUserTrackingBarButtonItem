`IIUserTrackingBarButtonItem` is a subclass of `UIBarButtonItem` that implements an interface very similar to `MKUserTrackingBarButtonItem`. `IIUserTrackingBarButtonItem` lets you set a separate subview for each of the three tracking states, `MKUserTrackingModeNone`; `MKUserTrackingModeFollow`; and `MKUserTrackingModeFollowWithHeading`.

    IIUserTrackingBarButtonItem *trackButton = [[IIUserTrackingBarButtonItem alloc] initWithMapView:self.mapView normalView:normalView followView:followView headingView:headingView];

Like `MKUserTrackingBarButtonItem`, the track button will automatically coordinate with an `MKMapView` to make sure that the map's tracking mode and the button's icon match. It also, of course, accepts taps to update the tracking mode.

There's also an `IIUserTrackingButton` that is the same thing except a subclass of `UIButton` instead of `UIBarButtonItem`. Damn you UIKit!

