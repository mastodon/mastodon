# encoding: utf-8

class Sanitize
  module Config
    BASIC = freeze_config(
      :elements => RESTRICTED[:elements] + %w[
        a abbr blockquote br cite code dd dfn dl dt kbd li mark ol p pre q s
        samp small strike sub sup time ul var
      ],

      :attributes => {
        'a'          => %w[href],
        'abbr'       => %w[title],
        'blockquote' => %w[cite],
        'dfn'        => %w[title],
        'q'          => %w[cite],
        'time'       => %w[datetime pubdate]
      },

      :add_attributes => {
        'a' => {'rel' => 'nofollow'}
      },

      :protocols => {
        'a'          => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]},
        'blockquote' => {'cite' => ['http', 'https', :relative]},
        'q'          => {'cite' => ['http', 'https', :relative]}
      }
    )
  end
end
