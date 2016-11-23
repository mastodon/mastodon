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

The linked public key file should be represented in PEM format.  For example, here's a 2048-bit RSA public key generated with `openssl` in PEM format:

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsdxyyeZHWJqLwj5zqm5s
wxKzKSrUlqsSw9s7tSCNZ2VptOmJYsELLyTt7xsXzfh14QiO9sYQ7oG6AxV2MEEO
vedTngHTeGSLXr+Hq0PpkUg74yyH5AJihPbtsOyQo1HMrKmPyoTLypSU8ahPKtLQ
oLFqCytYtf5vvFaLd+II2WWJphG/K9KLndOk38Ff+DqCvUxo7mOqn0I+o4EjjB6r
Fk3NQE/w0EiVehkv5KeW5WrOlF+z4xcrVN3z3+UoUZD+4j7uvUtXbHamTDTYpm/x
YY0Znamfxwefnj8vVy/UrUZbd41euMs+7z+pveYU0h4cCwJAXkdxUdpw10B6/3J+
cQIDAQAB
-----END PUBLIC KEY-----
```

### private

This block is expected to appear within a post.  As an example within an Atom feed:

```xml
<entry>
  <id>tag:mastodon.social,2016-11-23:objectId=166685:objectType=Status</id>
  <published>2016-11-23T11:09:10Z</published>
  <updated>2016-11-23T11:09:10Z</updated>
  <title>This is a private message</title>
  <content type="html">This is a private message</content>
  <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
  <link rel="self" type="application/atom+xml" href="https://mastodon.social/users/hq/updates/148372.atom"/>
  <link rel="alternate" type="text/html" href="https://mastodon.social/users/hq/updates/148372"/>
  <activity:object-type>http://activitystrea.ms/schema/1.0/comment</activity:object-type>
  <thr:in-reply-to ref="tag:mastodon.social,2016-11-23:objectId=166554:objectType=Status" href="https://mastodon.social/users/maize/updates/148167" type="text/html"/>
  <pm:private>
    <pm:encryptedContentBase64 encoding="utf-8">
      <!--
      the content is encrypted with a symmetric key (a new symmetric key is generated for each private message).  the symmetric key is
      then encrypted for each recipient using their public key
      -->
      dGhlIGNvbnRlbnQgaXMgZW5jcnlwdGVkIHdpdGggYSBzeW1tZXRyaWMga2V5IChhIG5ldyBzeW1tZXRyaWMga2V5IGlzIGdlbmVyYXRlZCBmb3IgZWFjaCBwcml2YXRlIG1lc3NhZ2UpLiAgdGhlIHN5bW1ldHJpYyBrZXkgaXMgdGhlbiBlbmNyeXB0ZWQgZm9yIGVhY2ggcmVjaXBpZW50IHVzaW5nIHRoZWlyIHB1YmxpYyBrZXk=
    </pm:encryptedContentBase64>
    <pm:recipient>
      <pm:canonicalUri>https://mastodon.social/users/user1.atom</pm:canonicalUri>
      <pm:publicKeyUri>https://mastodon.social/users/user1.pem</pm:publicKeyUri>
      <pm:encryptedSymmetricKey encoding="utf-8">
        <!--
        the symmetric key used to encrypt the actual content would be encrypted with the user's public key, and then included here in a base-64 format
        -->
        dGhlIHN5bW1ldHJpYyBrZXkgdXNlZCB0byBlbmNyeXB0IHRoZSBhY3R1YWwgY29udGVudCB3b3VsZCBiZSBlbmNyeXB0ZWQgd2l0aCB0aGUgdXNlcidzIHB1YmxpYyBrZXksIGFuZCB0aGVuIGluY2x1ZGVkIGhlcmUgaW4gYSBiYXNlLTY0IGZvcm1hdA==
      </pm:encryptedSymmetricKey>
    </pm:recipient>
    <pm:recipient>
      <pm:canonicalUri>https://mastodon.social/users/user2.atom</pm:canonicalUri>
      <pm:publicKeyUri>https://mastodon.social/users/user2.pem</pm:publicKeyUri>
      <pm:encryptedSymmetricKey encoding="utf-8">
        <!--
        the symmetric key used to encrypt the actual content would be encrypted with the user's public key, and then included here in a base-64 format
        -->
        dGhlIHN5bW1ldHJpYyBrZXkgdXNlZCB0byBlbmNyeXB0IHRoZSBhY3R1YWwgY29udGVudCB3b3VsZCBiZSBlbmNyeXB0ZWQgd2l0aCB0aGUgdXNlcidzIHB1YmxpYyBrZXksIGFuZCB0aGVuIGluY2x1ZGVkIGhlcmUgaW4gYSBiYXNlLTY0IGZvcm1hdA==
      </pm:encryptedSymmetricKey>
    </pm:recipient>
  </pm:private>
</entry>
```

As a convention, the unencrypted fields `content` and `title` should be replaced with `This is a private message`, but implementors may replace either
content with anything.  Implementors should ensure they do not add `<link>` tags (such as mentions) or any other data to the entry that reveals any part of the contents
of the private message.

** TODO** This is a work in progress.