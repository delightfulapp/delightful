Delightful for iPhone
==

Delightful is an unofficial [Trovebox](https://github.com/photo/frontend) iPhone/iPad app client. Available on the [App Store](https://itunes.apple.com/us/app/delightful-trovebox-photo/id878230610?ls=1&mt=8).

Screenshot
--

![Delightful app](https://github.com/delightfulapp/delightful/raw/master/delightful-iphone.png).

App Preview
--

[![Delightful App Preview](http://f.cl.ly/items/1K2k072D2W1m2X0b0o1k/Screen%20Shot%202014-12-06%20at%2002.12.31.png)](http://cl.ly/0g1Y0X06253s)


Features (so far)
--

2. View albums and tags.
3. Pinch to zoom in/out to see more or less photos. (change number of columns)
4. Download original photos and save to photo album.
5. Favorite photos.
5. Reverse Geocoding! If there is a photo with location within photos taken at the same date, the location name will be shown next to the date. Just like that of iOS 7 Photos app.
6. Browse All Photos.
7. Parallax effect on login page!
8. Offline viewing.
9. Share your Trovebox Photo's URL or original photo to Twitter/Facebook/Email.
10. View photo's camera data and tags.
11. 1password extension.
12. Sort photos, albums, and tags.
13. Upload photos with slide-to-select gestures to select multiple photos quickly and tap-and-hold to preview a photo.
14. Portrait and landscape mode.
15. iPhone 6 plus ready.
16. iOS 8 ready.
17. Smart tags. Automatically tag photos based on photos' metadata when uploading.
18. Guest login. Access a Trovebox server without logging in. You can only see public photos, albums, and tags; You cannot upload as guest either.

Requirements
--

1. [iOS 8](https://developer.apple.com/devcenter/ios/index.action).
2. [Cocoapods](http://cocoapods.org/).

How to
--

1. After cloning: `pod install`
2. Open `Delightful.xcworkspace`.
2. Build and run!

Development server
--

You can run development server using [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org). Once they're installed, go to `server` directory from command line, then run `vagrant up`. This will take time to boot and setup the development server.

After the server is booted, you need to add `192.168.56.101 trovebox.dev` to your `/etc/hosts` file, then flush the DNS: `sudo killall -HUP mDNSResponder`. You can then open your browser and go to `http://trovebox.dev` to setup your Trovebox server:

- Enter `127.0.0.1` for MySQL address.
- Enter `root` for MySQL user.
- Leave the MySQL password blank.

Contact
--

[@nicnocquee](https://twitter.com/nicnocquee)

Credits
--

Check out [Credits.md](https://github.com/delightfulapp/delightful/blob/master/Credits.md)


License
--

Delightful is available under the MIT license. See the LICENSE file for more info.
