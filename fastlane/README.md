fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios create
```
fastlane ios create
```
Creates App
### ios add_devices
```
fastlane ios add_devices
```
Adds devices
### ios bootstrap
```
fastlane ios bootstrap
```
Creates development and stuff
### ios gen_test
```
fastlane ios gen_test
```
Used to test the generator
### ios offline
```
fastlane ios offline
```
Used to test the generator when offline
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to HockeyApp

This will also make sure the profile is up to date
### ios deploy
```
fastlane ios deploy
```
Deploy a new version to the App Store

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
