PhotoBox
==

PhotoBox is a unofficial [Trovebox](https://trovebox.com/) iPhone app client. This is an experiment.

Features (so far)
--

1. Albums as initial point of navigation.
2. Photos grouped by date taken.
3. Pinch to zoom in/out to see more or less photos. (change number of columns)
4. View original photos and save to photo album, share to Twitter/Facebook/Email, or open in other apps.

Requirements
--

1. [iOS 7](https://developer.apple.com/devcenter/ios/index.action).
2. [Xcode 5](https://developer.apple.com/devcenter/ios/index.action).
3. [Cocoapods](http://cocoapods.org/).

How to
--

1. After cloning: `pod install`
2. Get consumer key, secret, oauth token, and secret at your [Trovebox's Settings](https://nicnocquee.trovebox.com/manage/settings#apps) page.
3. On Trovebox's Settings page, click `Create New App`, put any app name.
4. Copy your consumer key, secret, oauth token, and secret and put it in `PhotoBoxViewController.m` file inside `setupConnectionManager` method. Remove the `#error`.
5. Build and run!

License
--

PhotoBox is available under the MIT license. See the LICENSE file for more info.