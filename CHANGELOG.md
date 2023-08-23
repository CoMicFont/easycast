## 1.8.0

* Modernize, upgrade all ruby dependencies.

* Assets are now served by a Rack::Static middleward instead of Sprockets
  in production mode. Webassets are also moved to the public/ folder and
  provided pre-compiled as part of the release process instead of being
  located within the scenes and generated on the raspberry itself.

* The WiFI configuration is changed to something more stable on Raspberry pi4.
  The 5Ghz band is used instead of 2.4Ghz since experience seems to confirm that
  Wifi+HDMI+USB is unstable with 2.4Ghz.

  https://indilib.org/forum/general/6576-pi4-usb3-and-wireless-2-4ghz-interference.html#50509


## 1.7.0 - 2023-01-27

* Add better error handling, for easier start recovery when the scenes
  are wrong for some reason.

## 1.6.2 - 2019-10-23

* Add fixes for easycast to work under Windows

* Add `bundle exec rake check` that verifies the integrity of the scenes.yml
  file and existence of all asset files.

## 1.6.1 - 2019-05-28

* Add robustness to sourced events being lost, through an active
  2500ms retry strategy

## 1.6.0 - 2019-04-24

...
