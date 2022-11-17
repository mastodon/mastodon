# frozen_string_literal: true

class PrivacyPolicy < ActiveModelSerializers::Model
  DEFAULT_PRIVACY_POLICY = <<~TXT
    This privacy policy describes how %{domain} ("%{domain}", "we", "us") collects, protects and uses the personally identifiable information you may provide through the %{domain} website or its API. The policy also describes the choices available to you regarding our use of your personal information and how you can access and update this information. This policy does not apply to the practices of companies that %{domain} does not own or control, or to individuals that %{domain} does not employ or manage.

    # What information do we collect?

    - **Basic account information**: If you register on this server, you may be asked to enter a username, an e-mail address and a password. You may also enter additional profile information such as a display name and biography, and upload a profile picture and header image. The username, display name, biography, profile picture and header image are always listed publicly.
    - **Posts, following and other public information**: The list of people you follow is listed publicly, the same is true for your followers. When you submit a message, the date and time is stored as well as the application you submitted the message from. Messages may contain media attachments, such as pictures and videos. Public and unlisted posts are available publicly. When you feature a post on your profile, that is also publicly available information. Your posts are delivered to your followers, in some cases it means they are delivered to different servers and copies are stored there. When you delete posts, this is likewise delivered to your followers. The action of reblogging or favouriting another post is always public.
    - **Direct and followers-only posts**: All posts are stored and processed on the server. Followers-only posts are delivered to your followers and users who are mentioned in them, and direct posts are delivered only to users mentioned in them. In some cases it means they are delivered to different servers and copies are stored there. We make a good faith effort to limit the access to those posts only to authorized persons, but other servers may fail to do so. Therefore it's important to review servers your followers belong to. You may toggle an option to approve and reject new followers manually in the settings. **Please keep in mind that the operators of the server and any receiving server may view such messages**, and that recipients may screenshot, copy or otherwise re-share them. **Do not share any sensitive information over Mastodon.**
    - **IPs and other metadata**: When you log in, we record the IP address you log in from, as well as the name of your browser application. All the logged in sessions are available for your review and revocation in the settings. The latest IP address used is stored for up to 12 months. We also may retain server logs which include the IP address of every request to our server.

    # What do we use your information for?

    Any of the information we collect from you may be used in the following ways:

    - To provide the core functionality of Mastodon. You can only interact with other people's content and post your own content when you are logged in. For example, you may follow other people to view their combined posts in your own personalized home timeline.
    - To aid moderation of the community, for example comparing your IP address with other known ones to determine ban evasion or other violations.
    - The email address you provide may be used to send you information, notifications about other people interacting with your content or sending you messages, and to respond to inquiries, and/or other requests or questions.

    # How do we protect your information?

    We implement a variety of security measures to maintain the safety of your personal information when you enter, submit, or access your personal information. Among other things, your browser session, as well as the traffic between your applications and the API, are secured with SSL, and your password is hashed using a strong one-way algorithm. You may enable two-factor authentication to further secure access to your account.

    # What is our data retention policy?

    We will make a good faith effort to:

    - Retain server logs containing the IP address of all requests to this server, in so far as such logs are kept, no more than 90 days.
    - Retain the IP addresses associated with registered users no more than 12 months.

    You can request and download an archive of your content, including your posts, media attachments, profile picture, and header image.

    You may irreversibly delete your account at any time.

    # Do we use cookies?

    Yes. Cookies are small files that a site or its service provider transfers to your computer's hard drive through your Web browser (if you allow). These cookies enable the site to recognize your browser and, if you have a registered account, associate it with your registered account.

    We use cookies to understand and save your preferences for future visits.

    # Do we disclose any information to outside parties?

    We do not sell, trade, or otherwise transfer to outside parties your personally identifiable information. This does not include trusted third parties who assist us in operating our site, conducting our business, or servicing you, so long as those parties agree to keep this information confidential. We may also release your information when we believe release is appropriate to comply with the law, enforce our site policies, or protect ours or others rights, property, or safety.

    Your public content may be downloaded by other servers in the network. Your public and followers-only posts are delivered to the servers where your followers reside, and direct messages are delivered to the servers of the recipients, in so far as those followers or recipients reside on a different server than this.

    When you authorize an application to use your account, depending on the scope of permissions you approve, it may access your public profile information, your following list, your followers, your lists, all your posts, and your favourites. Applications can never access your e-mail address or password.

    # Site usage by children

    If this server is in the EU or the EEA: Our site, products and services are all directed to people who are at least 16 years old. If you are under the age of 16, per the requirements of the GDPR (General Data Protection Regulation) do not use this site.

    If this server is in the USA: Our site, products and services are all directed to people who are at least 13 years old. If you are under the age of 13, per the requirements of COPPA (Children's Online Privacy Protection Act) do not use this site.

    Law requirements can be different if this server is in another jurisdiction.

    ___

    This document is CC-BY-SA. Originally adapted from the [Discourse privacy policy](https://github.com/discourse/discourse).
  TXT

  DEFAULT_UPDATED_AT = DateTime.new(2022, 10, 7).freeze

  attributes :updated_at, :text

  def self.current
    custom = Setting.find_by(var: 'site_terms')

    if custom&.value.present?
      new(text: custom.value, updated_at: custom.updated_at)
    else
      new(text: DEFAULT_PRIVACY_POLICY, updated_at: DEFAULT_UPDATED_AT)
    end
  end
end
