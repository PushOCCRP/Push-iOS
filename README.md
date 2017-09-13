# Push-iOS
This is the repository for the iOS app portion of the Push app ecosystem. Theoretically, you should never have to actually touch this code. The idea is that it is pulled once, and sits in a folder. The generator will then automatically customize and build the code.

# Features
- Offline caching of stories
- Push notification support
- Analytics support
- In-line images in stories
- YouTube player support

# Set Up

_Note: This is a bit touchy, and needs some work. If you have problems please open an issue with your OS and error message and I'll get back you_

### Requirements
- An Apple computer with MacOS on it (10.12.6 is the latest as of writing)
- Latest version of XCode
- Ruby 2.3 or greater installed ([rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) work well to do this easily)
- A running [Push backend](https://github.com/PushOCCRP/Push-Backend) somewhere

### Setup
- To set up a version that will build and connect to a proper backend we use the [Push-Generator](https://github.com/PushOCCRP/Push-Generator) Please see the README there for further instructions.

### Development Notes
_I *really* hope to automate a lot of this at somepoint, but it's a bit difficult with everyone's own setups_

- Please set up the generator first.
- While this entire code base is in Objective-C for the moment, I'm not against going towards Swift. A full rewrite is not in the cards as the moment though.