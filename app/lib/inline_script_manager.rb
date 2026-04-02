# frozen_string_literal: true

require 'singleton'

class InlineScriptManager
  include Singleton
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::JavaScriptHelper

  def initialize
    @cached_files = {}
  end

  def file(name)
    @cached_files[name] ||= load_file(name)
  end

  private

  def load_file(name)
    path = Pathname.new(name).cleanpath
    raise ArgumentError, "Invalid inline javascript path: #{path}" if path.to_s.start_with?('..')

    path = Rails.root.join('app', 'javascript', 'inline', path)

    contents = javascript_cdata_section(path.read)
    digest = Digest::SHA256.base64digest(contents)

    { contents:, digest: }
  end
end
