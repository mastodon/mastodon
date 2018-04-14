# WebPush

[![Code Climate](https://codeclimate.com/github/zaru/webpush/badges/gpa.svg)](https://codeclimate.com/github/zaru/webpush)
[![Build Status](https://travis-ci.org/zaru/webpush.svg?branch=master)](https://travis-ci.org/zaru/webpush)
[![Gem Version](https://badge.fury.io/rb/webpush.svg)](https://badge.fury.io/rb/webpush)

This gem makes it possible to send push messages to web browsers from Ruby backends using the [Web Push Protocol](https://tools.ietf.org/html/draft-ietf-webpush-protocol-10). It supports [Message Encryption for Web Push](https://tools.ietf.org/html/draft-ietf-webpush-encryption) to send messages securely from server to user agent.

Payload is supported by Chrome50+, Firefox48+.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'webpush'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webpush

## Usage

Sending a web push message to a visitor of your website requires a number of steps:

1. Your server has (optionally) generated (one-time) a set of [Voluntary Application server Identification (VAPID)](https://tools.ietf.org/html/draft-ietf-webpush-vapid-01) keys. Otherwise, to send messages through Chrome, you have registered your site through the [Google Developer Console](https://console.developers.google.com/) and have obtained a GCM sender id and GCM API key from your app settings.
2. A `manifest.json` file, linked from your user's page, identifies your app settings.
3. Also in the user's web browser, a `serviceWorker` is installed and activated and its `pushManager` property is subscribed to push events with your VAPID public key, with creates a `subscription` JSON object on the client side.
4. Your server uses the `webpush` gem to send a notification with the `subscription` obtained from the client and an optional payload (the message).
5. Your service worker is set up to receive `'push'` events. To trigger a desktop notification, the user has accepted the prompt to receive notifications from your site.

### Generating VAPID keys

Use `webpush` to generate a VAPID key that has both a `public_key` and `private_key` attribute to be saved on the server side.

```ruby
# One-time, on the server
vapid_key = Webpush.generate_key

# Save these in your application server settings
vapid_key.public_key
vapid_key.private_key
```

### Declaring manifest.json

Check out the [Web Manifest docs](https://developer.mozilla.org/en-US/docs/Web/Manifest) for details on what to include in your `manifest.json` file. If using VAPID, no app credentials are needed.

```javascript
{
  "name": "My Website"
}
```
For Chrome web push, add the GCM sender id to a `manifest.json`.

```javascript
{
  "name": "My Website",
  "gcm_sender_id": "1006629465533"
}
```

The file is served within the scope of your service worker script, like at the root, and link to it somewhere in the `<head>` tag:

```html
<!-- index.html -->
<link rel="manifest" href="/manifest.json" />
```

### Installing a service worker

Your application javascript must register a service worker script at an appropriate scope (we're sticking with the root).

```javascript
// application.js
// Register the serviceWorker script at /serviceworker.js from your server if supported
if (navigator.serviceWorker) {
  navigator.serviceWorker.register('/serviceworker.js')
  .then(function(reg) {
     console.log('Service worker change, registered the service worker');
  });
}
// Otherwise, no push notifications :(
else {
  console.error('Service worker is not supported in this browser');
}
```

### Subscribing to push notifications

#### With VAPID

The VAPID public key you generated earlier is made available to the client as a `UInt8Array`. To do this, one way would be to expose the urlsafe-decoded bytes from Ruby to JavaScript when rendering the HTML template. (Global variables used here for simplicity).

```javascript
window.vapidPublicKey = new Uint8Array(<%= Base64.urlsafe_decode64(ENV['VAPID_PUBLIC_KEY']).bytes %>);
```

Your application javascript uses the `navigator.serviceWorker.pushManager` to subscribe to push notifications, passing the VAPID public key to the subscription settings.

```javascript
// application.js
// When serviceWorker is supported, installed, and activated,
// subscribe the pushManager property with the vapidPublicKey
navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
  serviceWorkerRegistration.pushManager
  .subscribe({
    userVisibleOnly: true,
    applicationServerKey: window.vapidPublicKey
  });
});
```

#### Without VAPID

If you will not be sending VAPID details, then there is no need generate VAPID keys, and the `applicationServerKey` parameter may be omitted from the `pushManager.subscribe` call.

```javascript
// application.js
// When serviceWorker is supported, installed, and activated,
// subscribe the pushManager property with the vapidPublicKey
navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
  serviceWorkerRegistration.pushManager
  .subscribe({
    userVisibleOnly: true
  });
});
```

### Triggering a web push notification

Hook into an client-side or backend event in your app to deliver a push message. The server must be made aware of the `subscription`. In the example below, we send the JSON generated subscription object to our backend at the "/push" endpoint with a message.

```javascript
// application.js
// Send the subscription and message from the client for the backend
// to set up a push notification
$(".webpush-button").on("click", (e) => {
  navigator.serviceWorker.ready
  .then((serviceWorkerRegistration) => {
    serviceWorkerRegistration.pushManager.getSubscription()
    .then((subscription) => {
      $.post("/push", { subscription: subscription.toJSON(), message: "You clicked a button!" });
    });
  });
});
```

Imagine a Ruby app endpoint that responds to the request by triggering notification through the `webpush` gem.

```ruby
# app.rb
# Use the webpush gem API to deliver a push notiifcation merging
# the message, subscription values, and vapid options
post "/push" do
  Webpush.payload_send(
    message: params[:message],
    endpoint: params[:subscription][:endpoint],
    p256dh: params[:subscription][:keys][:p256dh],
    auth: params[:subscription][:keys][:auth],
    vapid: {
      subject: "mailto:sender@example.com",
      public_key: ENV['VAPID_PUBLIC_KEY'],
      private_key: ENV['VAPID_PRIVATE_KEY']
    }
  )
end
```

Note: the VAPID options should be omitted if the client-side subscription was
generated without the `applicationServerKey` parameter described earlier. You
would instead pass the GCM api key along with the api request as shown in the
Usage section below.

### Receiving the push event

Your `/serviceworker.js` script may respond to `'push'` events. One action it can take is to trigger desktop notifications by calling `showNotification` on the `registration` property.

```javascript
// serviceworker.js
// The serviceworker context can respond to 'push' events and trigger
// notifications on the registration property
self.addEventListener("push", (event) => {
  let title = (event.data && event.data.text()) || "Yay a message";
  let body = "We have received a push message";
  let tag = "push-simple-demo-notification-tag";
  let icon = '/assets/my-logo-120x120.png';

  event.waitUntil(
    self.registration.showNotification(title, { body, icon, tag })
  )
});
```

Before the notifications can be displayed, the user must grant permission for [notifications](https://developer.mozilla.org/en-US/docs/Web/API/notification) in a browser prompt, using something like the example below.

```javascript
// application.js

// Let's check if the browser supports notifications
if (!("Notification" in window)) {
  console.error("This browser does not support desktop notification");
}

// Let's check whether notification permissions have already been granted
else if (Notification.permission === "granted") {
  console.log("Permission to receive notifications has been granted");
}

// Otherwise, we need to ask the user for permission
else if (Notification.permission !== 'denied') {
  Notification.requestPermission(function (permission) {
    // If the user accepts, let's create a notification
    if (permission === "granted") {
      console.log("Permission to receive notifications has been granted");
    }
  });
}
```

If everything worked, you should see a desktop notification triggered via web
push. Yay!

Note: if you're using Rails, check out [serviceworker-rails](https://github.com/rossta/serviceworker-rails), a gem that makes it easier to host serviceworker scripts and manifest.json files at canonical endpoints (i.e., non-digested URLs) while taking advantage of the asset pipeline.

## API

### With a payload

```ruby
message = {
  title: "title",
  body: "body",
  icon: "http://example.com/icon.pn"
}

Webpush.payload_send(
  endpoint: "https://fcm.googleapis.com/gcm/send/eah7hak....",
  message: JSON.generate(message),
  p256dh: "BO/aG9nYXNkZmFkc2ZmZHNmYWRzZmFl...",
  auth: "aW1hcmthcmFpa3V6ZQ==",
  ttl: 600 #optional, ttl in seconds, defaults to 2419200 (4 weeks),
)
```

### Without a payload

```ruby
Webpush.payload_send(
  endpoint: "https://fcm.googleapis.com/gcm/send/eah7hak....",
  p256dh: "BO/aG9nYXNkZmFkc2ZmZHNmYWRzZmFl...",
  auth: "aW1hcmthcmFpa3V6ZQ=="
)
```

### With VAPID

VAPID details are given as a hash with `:subject`, `:public_key`, and
`:private_key`. The `:subject` is a contact URI for the application server as either a "mailto:" or an "https:" address. The `:public_key` and `:private_key` should be passed as the base64-encoded values generated with `Webpush.generate_key`.

```ruby
Webpush.payload_send(
  endpoint: "https://fcm.googleapis.com/gcm/send/eah7hak....",
  message: "A message",
  p256dh: "BO/aG9nYXNkZmFkc2ZmZHNmYWRzZmFl...",
  auth: "aW1hcmthcmFpa3V6ZQ==",
  vapid: {
    subject: "mailto:sender@example.com"
    public_key: ENV['VAPID_PUBLIC_KEY'],
    private_key: ENV['VAPID_PRIVATE_KEY']
  }
)
```

### With GCM api key

```ruby
Webpush.payload_send(
  endpoint: "https://fcm.googleapis.com/gcm/send/eah7hak....",
  message: "A message",
  p256dh: "BO/aG9nYXNkZmFkc2ZmZHNmYWRzZmFl...",
  auth: "aW1hcmthcmFpa3V6ZQ==",
  api_key: "<GCM API KEY>"
)
```

### ServiceWorker sample

see. https://github.com/zaru/web-push-sample

p256dh and auth generate sample code.

```javascript
navigator.serviceWorker.ready.then(function(sw) {
  Notification.requestPermission(function(permission) {
    if(permission !== 'denied') {
      sw.pushManager.subscribe({userVisibleOnly: true}).then(function(s) {
        var data = {
          endpoint: s.endpoint,
          p256dh: btoa(String.fromCharCode.apply(null, new Uint8Array(s.getKey('p256dh')))).replace(/\+/g, '-').replace(/\//g, '_'),
          auth: btoa(String.fromCharCode.apply(null, new Uint8Array(s.getKey('auth')))).replace(/\+/g, '-').replace(/\//g, '_')
        }
        console.log(data);
      });
    }
  });
});
```

payloads received sample code.

```javascript
self.addEventListener("push", function(event) {
  var json = event.data.json();
  self.registration.showNotification(json.title, {
    body: json.body,
    icon: json.icon
  });
});
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zaru/webpush.
