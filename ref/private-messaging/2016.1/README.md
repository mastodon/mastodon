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


    <!-- public key URI element -->
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
      <pm:encryptedSymmetricKey format="aes-256-cbc">
        <!--
        the symmetric key used to encrypt the actual content would be encrypted with the user's public key, and then included here in a base-64 format
        -->
        dGhlIHN5bW1ldHJpYyBrZXkgdXNlZCB0byBlbmNyeXB0IHRoZSBhY3R1YWwgY29udGVudCB3b3VsZCBiZSBlbmNyeXB0ZWQgd2l0aCB0aGUgdXNlcidzIHB1YmxpYyBrZXksIGFuZCB0aGVuIGluY2x1ZGVkIGhlcmUgaW4gYSBiYXNlLTY0IGZvcm1hdA==
      </pm:encryptedSymmetricKey>
    </pm:recipient>
    <pm:recipient>
      <pm:canonicalUri>https://mastodon.social/users/user2.atom</pm:canonicalUri>
      <pm:publicKeyUri>https://mastodon.social/users/user2.pem</pm:publicKeyUri>
      <pm:encryptedSymmetricKey format="aes-256-cbc">
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

For example, let's say we wanted to encrypt the message "hello" for the user `user1`.  `user1`'s public key is:

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyLzIfIMU6+Aeh/RK45kP
liWw/QDOp6I7n9lDNdCQ4x0rzUGiw5TEc6hprssWbRq1zcY4j6vTSGYFIaWi0XMW
woDN18+M7H8wrTlnyYCz2nP6lWT27vAUreGtWlRjE0IuxuWPlSfWhBY9de2uUazt
wBmKZdendV33X43IgoXZa14Zj1WqQjJuoeQ8AWDRSKk1pcAGVOVmgaqPYIWHOU87
6Qe1z3qGLTv5PwscibJhIFRJd2UO6plS4srkSRjlNk+Dsh4Ommw+Fxkc7Xveazao
omhFQIDZKUAT+mBREquony6YighGgnHaot1+lCPD2bi33xhBu9uEXxk9nT3cWSsb
swIDAQAB
-----END PUBLIC KEY-----
```

Their private key, which only their instance would have a copy of:

```
-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDIvMh8gxTr4B6H
9ErjmQ+WJbD9AM6nojuf2UM10JDjHSvNQaLDlMRzqGmuyxZtGrXNxjiPq9NIZgUh
paLRcxbCgM3Xz4zsfzCtOWfJgLPac/qVZPbu8BSt4a1aVGMTQi7G5Y+VJ9aEFj11
7a5RrO3AGYpl16d1XfdfjciChdlrXhmPVapCMm6h5DwBYNFIqTWlwAZU5WaBqo9g
hYc5TzvpB7XPeoYtO/k/CxyJsmEgVEl3ZQ7qmVLiyuRJGOU2T4OyHg6abD4XGRzt
e95rNqiiaEVAgNkpQBP6YFESq6ifLpiKCEaCcdqi3X6UI8PZuLffGEG724RfGT2d
PdxZKxuzAgMBAAECggEATq5whx16HdqDHRcMI5njGh87+G9QkTRt2oH2bimKIPtW
J+YKPk8ZkZv5kKHZ8Hn/uOBxWx8mecJDUKTz5NUPnr2N8YFQ44IXOk6996WS2ZWM
KvKgN5ezA1Tp9fYNv4a5fwyL8xLianOtM4QuR6VYq2tXbAPTh5WFWNbiOQbt6b8O
mMsDgtdwp/4s/K4g0zLa7cXF89+0PqwgJ+hBM1Fc8FNyYhcpV1g0CsviLNVO2II/
VknbjMBaFv1K44tKaYP+H1AdJuFmsCeGaoDp+3wx3Ay7BKn86c4NIkSGcT9hyJUy
FKdzMC4g1O15t+wtULeFc7cMzWlTr1rr4G/hb0JegQKBgQDvtDdkS8HCM64bH9qG
+zwvFl7wDLuQgFYw2F0McNnkBUz+3k1r6HnxiRLB0R3CQGoCdH4yOsCsS1U+3pZe
0jC4u5kRU102zv5D8meRdACAjAZdTNuEddMpaKNmkYOsKF7WVcyZH3HTx7oMRUKU
L1dGquFezL+sHkZfu52ZP18vawKBgQDWYmWqMxUImW8+CD2Ge3iGWsDM/1E4Kfxx
d2ldkVeaXTpUL6p6MZu6WMVwjwxpeuQ4QbbE3NpBvrDdItq447Kbu3XMBFeu2Z9d
yLL9g8lbbbJHcxPlIGGbFFAA2ZgM970TgY1Rd2WWaXdU6klV9wdewUjR1AVFeJDm
sozevAA+2QKBgQCrU4oL28HfhoS4ymms9MEtfrXYqaEeRTxVqS/IhpiWS9ueh1Gb
AQy3wJtxgH/eqZ+bpZvVVv0DqMyDJSEhIObGAwACzCzh0c0Wz5mK8viw6GRcJ2T3
JigJfsrbssIEOM6gL68O+tSm5ChsQMy3kaa10clHstyErxbpsfWQ5SSphQKBgQCF
nKu6CL4qLt5q7d3Si+9Q5QzWdqWa+GfyG7cabrQHa+UnhNGd+H8TA7KB9VWKA+Jq
wWH0jaSlZwB5wfhJVPgDITFIZshzHAS8AZK0d8ct6U88Qpd6rNTIPz+hV/vw0RIR
LyPxSxWQScjqrl3oat44CwSkaZyjcIH2lf8/7jHE+QKBgQC7N5cV6UhN6Euc7PFr
xKgxUyYtF4ViJ20AcqSfrASKH/Bazsyfgd60NtHr2KWXoWi2YRyKZkuQTTtbumOo
NL2GLaMIwiq9tOrOZAqRsMGwSwx1hCiQ1+XjOPHenNopr2vPVPKzpnbKK3l3Uu3J
lUlAl2j+bjcbJ9nqJckquVA6bw==
-----END PRIVATE KEY-----
```

As the instance sending the private message, we would first generate a symmetric key for this post:

```
$ openssl rand -base64 32 > key.bin

$ cat key.bin
LVU+/YZASJnOUWvZkuk2fpeA0+OFwf6LMNInJkjTdUs=
```

Then we encrypt the symmetric key using the user's public key:

```
$ openssl rsautl -encrypt -inkey public_key.pem -pubin -in key.bin -out key.bin.enc

$ cat key.bin.enc
<encrypted binary data will be shown here>
```

Then we encrypt the post using the symmetric key that we know:

```
$ openssl enc -aes-256-cbc -salt -in plaintext.txt -out encrypted.bin -pass file:./key.bin

$ cat encrypted.bin
<encrypted binary data will be shown here>
```

Now we have our two encrypted pieces of content:

* `encrypted.bin` - the message encrypted with the symmetric key
* `key.bin.enc` - the symmetric key encrypted with `user1`'s public key

Convert them to their base-64 representations:

```
$ base64 encrypted.bin
U2FsdGVkX19GuBT+KBmtha4yYrWQGJDtgtcybT6r43I=

$ base64 key.bin.enc
Ca0Yp/wsc5yvwT7ZumNGoeuGi32FFR9VKTio0b+5neE3J1biU5yIhEvrJBeF+0/98dZSsBMqSte0
MfKQGd3+u6Uk/OtfDFPmitdMIjUbKpbmAIwql9m7Xs47FboCu9cKMjO7ZHU7B9kiBrZPcKo9mK6C
Xz1jvr1qQX5JRDNZ5gvCoA6kSjiEkj/8kNEdPFfbR4ZnD3mOYyRDizsNj3vkbLlIfnLiN2p2hIuK
NV9BoqX6ZXgoqWtAe54iMxMsWCvbBACzS+ipWFDpEdXJYu3GzRwRqfRCVDHS2Ci0MbJb2MsdbfVc
aiwJ2Owc926vXPAB2E0ctucafKpiAm5AaNYMKw==
```

Construct the `<private>` tag for the message appropriately:

```xml
<pm:private>
  <pm:encryptedContentBase64 encoding="utf-8">U2FsdGVkX19GuBT+KBmtha4yYrWQGJDtgtcybT6r43I=</pm:encryptedContentBase64>
  <pm:recipient>
    <pm:canonicalUri>https://mastodon.social/users/user1.atom</pm:canonicalUri>
    <pm:publicKeyUri>https://mastodon.social/users/user1.pem</pm:publicKeyUri>
    <pm:encryptedSymmetricKey format="aes-256-cbc">
      Ca0Yp/wsc5yvwT7ZumNGoeuGi32FFR9VKTio0b+5neE3J1biU5yIhEvrJBeF+0/98dZSsBMqSte0
      MfKQGd3+u6Uk/OtfDFPmitdMIjUbKpbmAIwql9m7Xs47FboCu9cKMjO7ZHU7B9kiBrZPcKo9mK6C
      Xz1jvr1qQX5JRDNZ5gvCoA6kSjiEkj/8kNEdPFfbR4ZnD3mOYyRDizsNj3vkbLlIfnLiN2p2hIuK
      NV9BoqX6ZXgoqWtAe54iMxMsWCvbBACzS+ipWFDpEdXJYu3GzRwRqfRCVDHS2Ci0MbJb2MsdbfVc
      aiwJ2Owc926vXPAB2E0ctucafKpiAm5AaNYMKw==
    </pm:encryptedSymmetricKey>
  </pm:recipient>
</pm:private>
```

When an instance receives a post with a private element, and recognises the canonical URI of a recipient as residing
on that instance, it attempts to decrypt the symmetric key using the private key of the user.  As an example, this
can be done with:

```
$ openssl rsautl -decrypt -inkey private_key.pem -in key.bin.enc -out key.bin

$ cat key.bin
LVU+/YZASJnOUWvZkuk2fpeA0+OFwf6LMNInJkjTdUs=
```

```
$ openssl enc -d -aes-256-cbc -in encrypted.bin -out plaintext2.txt -pass file:./key.bin

$ cat plaintext2.txt
hello
```