# frozen_string_literal: true
#
# Mastodon, a GNU Social-compatible microblogging server
# Copyright (C) 2016-2017 Eugen Rochko & al (see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class FetchLinkCardService < BaseService
  include HttpHelper

  URL_PATTERN = %r{https?://\S+}

  def call(status)
    # Get first http/https URL that isn't local
    url = status.text.match(URL_PATTERN).to_a.reject { |uri| TagManager.instance.local_url?(uri) }.first

    return if url.nil?

    url = Addressable::URI.parse(url).normalize.to_s
    card = PreviewCard.where(status: status).first_or_initialize(status: status, url: url)
    attempt_opengraph(card, url) unless attempt_oembed(card, url)
  end

  private

  def attempt_oembed(card, url)
    response = OEmbed::Providers.get(url)

    card.type          = response.type
    card.title         = response.respond_to?(:title)         ? response.title         : ''
    card.author_name   = response.respond_to?(:author_name)   ? response.author_name   : ''
    card.author_url    = response.respond_to?(:author_url)    ? response.author_url    : ''
    card.provider_name = response.respond_to?(:provider_name) ? response.provider_name : ''
    card.provider_url  = response.respond_to?(:provider_url)  ? response.provider_url  : ''
    card.width         = 0
    card.height        = 0

    case card.type
    when 'link'
      card.image = URI.parse(response.thumbnail_url) if response.respond_to?(:thumbnail_url)
    when 'photo'
      card.url    = response.url
      card.width  = response.width.presence  || 0
      card.height = response.height.presence || 0
    when 'video'
      card.width  = response.width.presence  || 0
      card.height = response.height.presence || 0
      card.html   = Formatter.instance.sanitize(response.html, Sanitize::Config::MASTODON_OEMBED)
    when 'rich'
      # Most providers rely on <script> tags, which is a no-no
      return false
    end

    card.save_with_optional_image!
  rescue OEmbed::NotFound
    false
  end

  def attempt_opengraph(card, url)
    response = http_client.get(url)

    return if response.code != 200 || response.mime_type != 'text/html'

    page = Nokogiri::HTML(response.to_s)

    card.type        = :link
    card.title       = meta_property(page, 'og:title') || page.at_xpath('//title')&.content
    card.description = meta_property(page, 'og:description') || meta_property(page, 'description')
    card.image       = URI.parse(Addressable::URI.parse(meta_property(page, 'og:image')).normalize.to_s) if meta_property(page, 'og:image')

    return if card.title.blank?

    card.save_with_optional_image!
  end

  def meta_property(html, property)
    html.at_xpath("//meta[@property=\"#{property}\"]")&.attribute('content')&.value || html.at_xpath("//meta[@name=\"#{property}\"]")&.attribute('content')&.value
  end
end
