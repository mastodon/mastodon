# frozen_string_literal: true
require 'hamlit/hamlit'
require 'hamlit/object_ref'
require 'hamlit/utils'

module Hamlit::AttributeBuilder
  BOOLEAN_ATTRIBUTES = %w[disabled readonly multiple checked autobuffer
                       autoplay controls loop selected hidden scoped async
                       defer reversed ismap seamless muted required
                       autofocus novalidate formnovalidate open pubdate
                       itemscope allowfullscreen default inert sortable
                       truespeed typemustmatch download].freeze
end
