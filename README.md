# ChatHeads-Extensions
These tweaks are designed to be installed and communicate (via RocketBootstrap) with ChatHeads.

The goal of these tweaks is to provide communications between applications such as stock iOS Messages, Facebook Messenger, WhatsApp, etc. and ChatHeads. Information such as the message body, contact photo, contact name, and thread-id will allow ChatHeads to present a head for the corresponding application


## Dumping Headers

To dump headers for client apps. Install BFDecrypt from level3tjg.github.io. Open BFDecrypt's settings, enable the app(s) you would like to decrypt. Open the apps, let BFDecrypt do its thing. Then on your computer run 
`nc xx.x.x.x 31336 > ~/Desktop/decrypted.ipa`. 

Unzip the .ipa

Find the executables you would like to dump the headers for. Facebook was tricky as the main executable is actually empty. Instead, navigate to /Messenger/Frameworks/ where you'll find different frameworks. Inside each framework is a different executable which I was able to dump.
(I have not included any .ipa's or headers due to legal reasons)

Once you have found the executables, run class-dump on them

`class-dump -o ./ -Hr [output-dir] [executable]`

You should now have the headers.

## Developing extensions

The existing tweaks are commented, so take a look at those. Each application is different but I'll outline the main implementation. 

When creating a `theos` tweak for ChatHeads, it must follow the naming convention of `MH[YourApp]Support.dylib` to allow the package to show up in ChatHeads "Installed Extensions" section. The package name name can be whatever you'd like (eg: `ChatHeads Facebook Messenger Support`, `FB Support`, `FB Messenger for ChatHeads`).

Don't forget to filter the BundleID of the target application.

In the AppDelegate, hook `application:didFinishLaunchingWithOptions:` and create an instance of RBS for `com.c1d3r.messagehub`.

Send the `registerExtension` message to ChatHeads, along with the app's bundleId, and add an observer for `openConversation`

I also send a `debug` message, telling ChatHeads the application was launched.

Next, you'll need to find the message received function. When that is called, we need to parse through the message to find all of the information. This includes `(NSString *) conversationId`, `(NSArray *) recipients`, `(NSString *) message`, and `(NSString *) bundleId`.

Here is an example of what should be sent to ChatHeads. All of these values will change depending on the client application, but it'll work with ChatHeads, since ChatHeads will just send this info back to the client app.

```
      [center sendMessageName:@"messageReceived" userInfo:@{
        @"conversationId" : @"00000001",
        @"recipients" : @[
                           {
                             @"name": @"c1d3r",
                             @"id": @"abc123",
                             @"imageData": UIImagePNGRepresentation([UIImage new])
                           }
                         ],
        @"message" : @"Hello there! This is an example of a message being recived by the client application!"
        @"bundleId" : [UIApplication displayIdentifier]
      }];

```

Hope this helps get you started. It comes down to a lot of trial and error. I've tried reverse engineering with tools like Hopper, but I've found the best way to find what your looking for is to just filter the dumped headers by method/class name.

The current tweaks (FB Messenger, SMS, WhatsApp) all very quite a bit, both due to experimenting with different implementations, as well as the how the developers of the apps have written them.

I've recently been in talks with a team who are working on a web-based solution for something similar, which may turn out to be a more reliable implementation due to being based in web-based protocols, rather than hooking a front end app receiving data from said web protocols.

## Publishing

In ChatHeads’ settings, I have a page to display the Available Extensions, then open them in Cydia (or Sileo). If you create an extension, let me know and I'll add it to the list of available extensions! I can also deploy it to my repo if you're interested.

If you have any questions, feel free to get in touch.

Twitter: @c1d3rdev
Email:   c1d3rdev@gmail.com
