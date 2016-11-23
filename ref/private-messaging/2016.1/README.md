# Private Messaging Spec 2016.1 (Draft)

This is a draft specification for supporting private, user-to-user messaging in a public federated system.  This is intended
for use in Mastodon and other implementors of OStatus.

## Schema / XSD

The XSD for private messaging is located at `schema.xsd`.  The XML namespace for the specification is 
`https://raw.githubusercontent.com/Gargron/mastodon/master/ref/private-messaging/2016.1/schema.xsd` (which aligns
with the raw XSD document for the spec).

## Implementation

These extension elements are intended to appear within Atom feeds and real-time transmissions of OStatus content.

### publicKeyUri

This element is expected to be included within `person` Activity Stream object.  As an example, this tag would be
included within `https://mastodon.social/users/hq.atom` for a Mastodon user.  An example of it's
inclusion would be:

```xml
<?xml version="1.0"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:thr="http://purl.org/syndication/thread/1.0" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:media="http://purl.org/syndication/atommedia" xmlns:pm="https://raw.githubusercontent.com/Gargron/mastodon/master/ref/private-messaging/2016.1/schema.xsd">
  <id>https://mastodon.social/users/hq.atom</id>
  <title>June</title>
  <subtitle>game developer - she/her - @hachque (Twitter) - https://www.redpointgames.com.au/ </subtitle>
  <updated>2016-11-23T11:09:10Z</updated>
  <logo>https://mastodon-social.s3-eu-central-1.amazonaws.com/accounts/avatars/000/011/569/medium/Avatar.jpg</logo>
  <author>
    <activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type>
    <uri>https://mastodon.social/users/hq</uri>
    <name>hq</name>
    <email>hq@mastodon.social</email>
    <summary>game developer - she/her - @hachque (Twitter) - https://www.redpointgames.com.au/ </summary>
    <link rel="alternate" type="text/html" href="https://mastodon.social/users/hq"/>
    <link rel="avatar" type="image/jpeg" media:width="300" media:height="300" href="https://mastodon-social.s3-eu-central-1.amazonaws.com/accounts/avatars/000/011/569/large/Avatar.jpg"/>
    <link rel="avatar" type="image/jpeg" media:width="96" media:height="96" href="https://mastodon-social.s3-eu-central-1.amazonaws.com/accounts/avatars/000/011/569/medium/Avatar.jpg"/>
    <link rel="avatar" type="image/jpeg" media:width="48" media:height="48" href="https://mastodon-social.s3-eu-central-1.amazonaws.com/accounts/avatars/000/011/569/small/Avatar.jpg"/>
    <poco:preferredUsername>hq</poco:preferredUsername>
    <poco:displayName>June</poco:displayName>
    <poco:note>game developer - she/her - @hachque (Twitter) - https://www.redpointgames.com.au/ </poco:note>
    <pm:publicKeyUri>https://mastodon.social/users/hq.pem</pm:publicKeyUri>
  </author>
  <link rel="alternate" type="text/html" href="https://mastodon.social/users/hq"/>
  <link rel="self" type="application/atom+xml" href="https://mastodon.social/users/hq.atom"/>
  <link rel="hub" href="https://pubsubhubbub.superfeedr.com"/>
  <link rel="salmon" href="https://mastodon.social/api/salmon/11569"/>
  <!-- ... -->
</feed>
```

The linked public key file should be represented in PEM format.

** TODO** This is a work in progress.