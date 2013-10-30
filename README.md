Delightful
==

![Delightful - Trovebox Photo Viewer](http://f.cl.ly/items/1e272y3F0j0o33221E2P/Photo%202013-09-06%2015%2027%2042.png)

Delightful is a unofficial [Trovebox](https://trovebox.com/) iPhone app client. This is an experiment.

Preview
--

[![](http://f.cl.ly/items/2g2e3e1p3c1l1I342Z1V/Screen%20Shot%202013-09-02%20at%207.06.52%20PM.png)](http://www.youtube.com/watch?v=PeeV3pGwme0)


Features (so far)
--

1. Albums as initial point of navigation.
2. Photos grouped by date taken.
3. Pinch to zoom in/out to see more or less photos. (change number of columns)
4. Download original photos and save to photo album.
5. Reverse Geocoding! If there is a photo with location within photos taken at the same date, the location name will be shown next to the date. Just like that of iOS 7 Photos app.
6. Browse All Photos.
7. Parallax effect on login page!
8. Core data support a.k.a you can see your photos and albums offline.
9. Share your Trovebox Photo's URL to Twitter/Facebook/Email.
10. View photo's camera data and tags.

Requirements
--

1. [iOS 7](https://developer.apple.com/devcenter/ios/index.action).
2. [Xcode 5](https://developer.apple.com/devcenter/ios/index.action).
3. [Cocoapods](http://cocoapods.org/).

How to
--

1. After cloning: `pod install`
2. ~~Copy `PhotoBox/Controllers/PhotoBoxViewController.m.stub` to `PhotoBox/Controllers/PhotoBoxViewController.m` (Same folder, remove .stub).~~
2. ~~Get consumer key, secret, oauth token, and secret at your [Trovebox's Settings](https://nicnocquee.trovebox.com/manage/settings#apps) page.~~
3. ~~On Trovebox's Settings page, click `Create New App`, put any app name.~~
4. ~~Copy your consumer key, secret, oauth token, and secret and put it in `PhotoBoxViewController.m` file inside `setupConnectionManager` method. Remove the `#error`.~~
5. Open `PhotoBox.xcworkspace`.
5. Build and run!

Contact
--

[@nicnocquee](https://twitter.com/nicnocquee)


License
--

Delightful is available under the MIT license. See the LICENSE file for more info.