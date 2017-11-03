# frozen_string_literal: true

require 'singleton'
require_relative './sanitize_config'

class Formatter
  include Singleton
  include RoutingHelper

  include ActionView::Helpers::TextHelper

  def format(status, options = {})
    if status.reblog?
      prepend_reblog = status.reblog.account.acct
      status         = status.proper
    else
      prepend_reblog = false
    end

    raw_content = status.text

    unless status.local?
      html = reformat(raw_content)
      html = encode_custom_emojis(html, status.emojis + status.avatar_emojis) if options[:custom_emojify]
      return html.html_safe # rubocop:disable Rails/OutputSafety
    end

    linkable_accounts = status.mentions.map(&:account)
    linkable_accounts << status.account

    html = raw_content
    html = "RT @#{prepend_reblog} #{html}" if prepend_reblog
    html = encode_and_link_urls(html, linkable_accounts)
    html = encode_custom_emojis(html, status.emojis + status.avatar_emojis) if options[:custom_emojify]
    #html = simple_format(html, {}, sanitize: false)
    #html = html.delete("\n")
    html = format_bbcode(html)
	html = markdown(html)
	html = clean_paragraphs(html)

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def format_enquete(enquete)
    raw_enquete_info = JSON.parse(enquete)
    enquete_info = {}
    question_html = encode_and_link_urls(raw_enquete_info['question'])
    question_html = simple_format(question_html, {}, sanitize: false)
    question_html = question_html.delete("\n")
    enquete_info['question'] = question_html.html_safe
    enquete_info['items'] = raw_enquete_info['items'].map do |item|
      encode_and_link_urls(item)
    end
    enquete_info['ratios'] = raw_enquete_info['ratios']
    enquete_info['ratios_text'] = raw_enquete_info['ratios_text']
    enquete_info['type'] = raw_enquete_info['type']
    enquete_info['duration'] = raw_enquete_info['duration']
    JSON.generate(enquete_info)
  end
  
  def reformat(html)
    sanitize(html, Sanitize::Config::MASTODON_STRICT)
  end

  def plaintext(status)
    return status.text if status.local?

    text = status.text.gsub(/(<br \/>|<br>|<\/p>)+/) { |match| "#{match}\n" }
    strip_tags(text)
  end
  
  def clean_paragraphs(html)
    html.gsub(/<p><\/p>/,"")
	html.gsub("\n","")
  end
  
  def simplified_format(account)
    return reformat(account.note).html_safe unless account.local? # rubocop:disable Rails/OutputSafety

    html = encode_and_link_urls(account.note)
    html = simple_format(html, {}, sanitize: false)
    html = html.delete("\n")
    html = format_bbcode(html)

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def sanitize(html, config)
    Sanitize.fragment(html, config)
  end

  def format_spoiler(status)
    html = encode(status.spoiler_text)
    html = encode_custom_emojis(html, status.emojis + status.avatar_emojis)
    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  private

  def encode(html)
    HTMLEntities.new.encode(html)
  end

  def encode_and_link_urls(html, accounts = nil)
    entities = Extractor.extract_entities_with_indices(html, extract_url_without_protocol: false)

    rewrite(html.dup, entities) do |entity|
      if entity[:url]
        link_to_url(entity)
      elsif entity[:hashtag]
        link_to_hashtag(entity)
      elsif entity[:screen_name]
        link_to_mention(entity, accounts)
      end
    end
  end

  def encode_custom_emojis(html, emojis)
    return html if emojis.empty?

    emoji_map = emojis.map { |e| [e.shortcode, full_asset_url(e.image.url)] }.to_h

    i                     = -1
    inside_tag            = false
    inside_shortname      = false
    shortname_start_index = -1

    while i + 1 < html.size
      i += 1

      if inside_shortname && html[i] == ':'
        shortcode = html[shortname_start_index + 1..i - 1]
        emoji     = emoji_map[shortcode]

        if emoji
          replacement = "<img draggable=\"false\" class=\"emojione\" alt=\":#{shortcode}:\" title=\":#{shortcode}:\" src=\"#{emoji}\" />"
          before_html = shortname_start_index.positive? ? html[0..shortname_start_index - 1] : ''
          html        = before_html + replacement + html[i + 1..-1]
          i          += replacement.size - (shortcode.size + 2) - 1
        else
          i -= 1
        end

        inside_shortname = false
      elsif inside_tag && html[i] == '>'
        inside_tag = false
      elsif html[i] == '<'
        inside_tag       = true
        inside_shortname = false
      elsif !inside_tag && html[i] == ':'
        inside_shortname      = true
        shortname_start_index = i
      end
    end

    html
  end

  def rewrite(text, entities)
    chars = text.to_s.to_char_a
	
    # Sort by start index
    entities = entities.sort_by do |entity|
      indices = entity.respond_to?(:indices) ? entity.indices : entity[:indices]
      indices.first
    end

    result = []

    last_index = entities.reduce(0) do |index, entity|
      indices = entity.respond_to?(:indices) ? entity.indices : entity[:indices]
      result << encode(chars[index...indices.first].join)
      result << yield(entity)
      indices.last
    end

    result << encode(chars[last_index..-1].join)

    result.flatten.join
  end

  def link_to_url(entity)
    normalized_url = Addressable::URI.parse(entity[:url]).normalize
    html_attrs     = { target: '_blank', rel: 'nofollow noopener' }

    Twitter::Autolink.send(:link_to_text, entity, link_html(entity[:url]), normalized_url, html_attrs)
  rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
    encode(entity[:url])
  end

  def link_to_mention(entity, linkable_accounts)
    acct = entity[:screen_name]

    return link_to_account(acct) unless linkable_accounts

    account = linkable_accounts.find { |item| TagManager.instance.same_acct?(item.acct, acct) }
    account ? mention_html(account) : "@#{acct}"
  end

  def link_to_account(acct)
    username, domain = acct.split('@')

    domain  = nil if TagManager.instance.local_domain?(domain)
    account = Account.find_remote(username, domain)

    account ? mention_html(account) : "@#{acct}"
  end

  def link_to_hashtag(entity)
    hashtag_html(entity[:hashtag])
  end

  def link_html(url)
    url    = Addressable::URI.parse(url).to_s
    prefix = url.match(/\Ahttps?:\/\/(www\.)?/).to_s
    text   = url[prefix.length, 30]
    suffix = url[prefix.length + 30..-1]
    cutoff = url[prefix.length..-1].length > 30

    "<span class=\"invisible\">#{encode(prefix)}</span><span class=\"#{cutoff ? 'ellipsis' : ''}\">#{encode(text)}</span><span class=\"invisible\">#{encode(suffix)}</span>"
  end

  def hashtag_html(tag)
    "<a href=\"#{tag_url(tag.downcase)}\" class=\"mention hashtag\" rel=\"tag\">#<span>#{tag}</span></a>"
  end

  def mention_html(account)
    "<span class=\"h-card\"><a href=\"#{TagManager.instance.url_for(account)}\" class=\"u-url mention\">@<span>#{account.username}</span></a></span>"
  end
  
  def markdown(html)
    # Bold + Italic

    html = html.gsub(/^&gt; (.*?)(\n|$)/m, '<blockquote>\1</blockquote>')

    renderer = MDRenderer.new(
      no_links: false,
      no_styles: true,
      no_images: true,
      hard_wrap: false,
      filter_html: false,
      escape_html: false
    )
    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: false,
      tables: true,
      strikethrough: true,
      fenced_code_blocks: true,
	  highlight: true,
	  quote: true,
	  no_intra_emphasis: true,
	  fenced_code_blocks: true,
	  lax_spacing: true,
	  superscript: true,
	  footnotes: true
    )
    html = markdown.render(html)

    html = html.gsub(/<\/blockquote><p><\/p><blockquote>/, '<br>') # Not so cool
	#html = html.gsub(/<br>\n<\/p>/, '</p>')
	#html = html.gsub(/<p><br>\n/, '<p>')

    html
  end
  
  def format_bbcode(html)
    
    begin
      html = html.bbcode_to_html(false, {
        :spin => {
          :html_open => '<span class="fa fa-spin">', :html_close => '</span>',
          :description => 'Make text spin',
          :example => 'This is [spin]spin[/spin].'},
        :pulse => {
          :html_open => '<span class="bbcode-pulse-loading">', :html_close => '</span>',
          :description => 'Make text pulse',
          :example => 'This is [pulse]pulse[/pulse].'},
        :b => {
          :html_open => '<span style="font-family: \'kozuka-gothic-pro\', sans-serif; font-weight: 900;">', :html_close => '</span>',
          :description => 'Make text bold',
          :example => 'This is [b]bold[/b].'},
        :i => {
          :html_open => '<span style="font-family: \'kozuka-gothic-pro\', sans-serif; font-style: italic; -moz-font-feature-settings: \'ital\'; -webkit-font-feature-settings: \'ital\'; font-feature-settings: \'ital\';">', :html_close => '</span>',
          :description => 'Make text italic',
          :example => 'This is [i]italic[/i].'},
        :flip => {
          :html_open => '<span class="fa fa-flip-%direction%">', :html_close => '</span>',
          :description => 'Flip text',
          :example => '[flip=horizontal]This is flip[/flip]',
          :allow_quick_param => true, :allow_between_as_param => false,
          :quick_param_format => /(horizontal|vertical)/,
          :quick_param_format_description => 'The size parameter \'%param%\' is incorrect, a number is expected',
          :param_tokens => [{:token => :direction}]},
        :large => {
          :html_open => '<span class="fa fa-%size%">', :html_close => '</span>',
          :description => 'Large text',
          :example => '[large=2x]Large text[/large]',
          :allow_quick_param => true, :allow_between_as_param => false,
          :quick_param_format => /(2x|3x|4x|5x)/,
          :quick_param_format_description => 'The size parameter \'%param%\' is incorrect, a number is expected',
          :param_tokens => [{:token => :size}]},
        :colorhex => {
          :html_open => '<span style="color: #%colorcode%">', :html_close => '</span>',
          :description => 'Use color code',
          :example => '[colorhex=ffffff]White text[/colorhex]',
          :allow_quick_param => true, :allow_between_as_param => false,
          :quick_param_format => /([0-9a-fA-F]{6})/,
          :quick_param_format_description => 'The size parameter \'%param%\' is incorrect',
          :param_tokens => [{:token => :colorcode}]},
      }, :enable, :i, :b, :color, :quote, :code, :size, :u, :s, :spin, :pulse, :flip, :large, :colorhex)
    rescue Exception => e
    end
    html
  end
end

class MDRenderer < Redcarpet::Render::HTML
  def header(text, _header_level)
    text
  end

  def block_code(code, lang)
    %(<pre><code class="block-code">#{code}</code></pre>)
  end

  def codespan(code)
    %(<code class="inline-code">#{code}</code>)
  end

  def link(link, title, content)
    title
  end

  def link_html(url)
    prefix = url.match(/\Ahttps?:\/\/(www\.)?/).to_s
    text   = url[prefix.length, 30]
    suffix = url[prefix.length + 30..-1]
    cutoff = url[prefix.length..-1].length > 30

    "<span class=\"invisible\">#{prefix}</span><span class=\"#{cutoff ? 'ellipsis' : ''}\">#{text}</span><span class=\"invisible\">#{suffix}</span>"
  end

  def autolink(link, link_type)
    "<a href=\"#{link}\" target=\"_blank\" rel=\"nofollow noopener\">#{link_html(link)}</a>"
  end
end

class MDRenderer < Redcarpet::Render::HTML
  def header(text, _header_level)
    text
  end

  def block_quote(quote)
    %(<blockquote><quote class="block_quote">#{code}</code></blockquote>)
  end

  def block_code(code, lang)
    %(<pre><code class="block-code">#{code}</code></pre>)
  end

  def codespan(code)
    %(<code class="inline-code">#{code}</code>)
  end
end
