# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )
# end

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'ActivityPub'
  inflect.acronym 'ActivityStreams'
  inflect.acronym 'ASCII'
  inflect.acronym 'CLI'
  inflect.acronym 'DeepL'
  inflect.acronym 'DSL'
  inflect.acronym 'JsonLd'
  inflect.acronym 'OEmbed'
  inflect.acronym 'OStatus'
  inflect.acronym 'PubSubHubbub'
  inflect.acronym 'REST'
  inflect.acronym 'RSS'
  inflect.acronym 'StatsD'
  inflect.acronym 'TOC'
  inflect.acronym 'URL'

  inflect.singular 'data', 'data'
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end
