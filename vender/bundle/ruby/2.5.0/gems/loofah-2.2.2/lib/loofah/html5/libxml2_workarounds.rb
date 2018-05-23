# coding: utf-8
require 'set'

module Loofah
  #
  #  constants related to working around unhelpful libxml2 behavior
  #
  #  ಠ_ಠ
  #
  module LibxmlWorkarounds
    #
    #  these attributes and qualifying parent tags are determined by the code at:
    #
    #    https://git.gnome.org/browse/libxml2/tree/HTMLtree.c?h=v2.9.2#n714
    #
    #  see comments about CVE-2018-8048 within the tests for more information
    #
    BROKEN_ESCAPING_ATTRIBUTES = Set.new %w[
        href
        action
        src
        name
      ]
    BROKEN_ESCAPING_ATTRIBUTES_QUALIFYING_TAG = {"name" => "a"}
  end
end
