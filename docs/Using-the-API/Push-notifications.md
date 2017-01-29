Push notifications
==================

Mastodon can communicate with the Firebase Cloud Messaging API to send push notifications to apps on users' devices. For this to work, these conditions must be met:

* Responsibility of an instance owner: `FCM_API_KEY` set on the instance. This can be obtained on the Firebase dashboard, in project settings, under Cloud Messaging, as "server key"
* Responsibility of the app developer: Firebase added/enabled in the Android/iOS app. [See Guide](https://firebase.google.com/docs/cloud-messaging/)

When the app obtains/refreshes a registration ID from Firebase, it needs to send that ID to the `/api/v1/devices/register` endpoint of the authorized user's instance via a POST request. The app can opt out of notifications by sending a similiar request with `unregister` instead of `register`.

The push notifications will be triggered by the notifications of the type you can normally find in `/api/v1/notifications`. However, the push notifications will not contain any inline content. They will contain JSON data of this format ("12" is an example value):

```json
{ "notification_id": 12 }
```

Your app can then retrieve the actual content of the notification from the `/api/v1/notifications/12` API endpoint.
