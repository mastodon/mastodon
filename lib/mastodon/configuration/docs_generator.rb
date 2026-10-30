# frozen_string_literal: true

require 'yaml'

module Mastodon
  module Configuration
    # Generates Hugo-flavored Markdown for `content/en/admin/config.md` from
    # a JSON Schema hash that contains `x-docs-layout` (the section tree) and
    # per-property `x-*` fields populated from `annotations.yml`.
    #
    # Usage:
    #   schema = JSON.parse(File.read('mastodon-config.schema.json'))
    #   puts Mastodon::Configuration::DocsGenerator.render(schema)
    #
    # Or via the rake task:
    #   bundle exec rails mastodon:config:docs > /path/to/content/en/admin/config.md
    module DocsGenerator
      def self.render(schema)
        layout    = schema['x-docs-layout']            || {}
        props     = schema['properties']               || {}
        docs_only = layout['docs_only_variables']      || {}
        all_vars  = props.merge(docs_only)

        warn_unlisted(layout, props)

        out = []
        out << emit_frontmatter(layout['frontmatter'])
        out << layout['intro'].to_s.strip unless layout['intro'].to_s.strip.empty?
        out << ''

        (layout['sections'] || []).each do |section|
          out << emit_section(section, all_vars)
        end

        out.join("\n").rstrip + "\n"
      end

      def self.warn_unlisted(layout, props)
        listed = collect_listed(layout)
        props.each_key do |var|
          next if listed.include?(var)
          group = props[var]['x-group']
          warn "WARNING: #{var} (group: #{group}) is not listed in any docs section tree subsection"
        end
      end
      private_class_method :warn_unlisted

      def self.collect_listed(layout)
        listed = []
        (layout['sections'] || []).each do |section|
          (section['subsections'] || []).each do |sub|
            listed.concat(sub['variables'] || [])
            (sub['subsections'] || []).each do |nested|
              listed.concat(nested['variables'] || [])
            end
          end
        end
        listed.to_set
      end
      private_class_method :collect_listed

      def self.emit_frontmatter(fm)
        return '' unless fm
        "---\n#{fm.to_yaml.sub(/\A---\n/, '')}---\n"
      end
      private_class_method :emit_frontmatter

      def self.emit_section(section, props)
        out = []
        anchor = section['anchor'] ? " {##{section['anchor']}}" : ''
        out << "## #{section['title']}#{anchor}"
        out << ''

        (section['page_refs'] || []).each { |p| out << emit_page_ref(p) }

        if section['intro']
          out << section['intro'].strip
          out << ''
        end

        (section['hints'] || []).each { |h| out << emit_hint(h) }

        (section['subsections'] || []).each do |sub|
          out << emit_subsection(sub, props)
        end

        out.join("\n")
      end
      private_class_method :emit_section

      def self.emit_subsection(sub, props, level: 3)
        out = []
        anchor = sub['anchor'] ? " {##{sub['anchor']}}" : ''
        out << "#{'#' * level} #{sub['title']}#{anchor}"
        out << ''

        (sub['page_refs'] || []).each { |p| out << emit_page_ref(p) }

        if sub['pre_version_history']
          out << version_history_block(sub['pre_version_history'])
          out << ''
        end

        (sub['pre_hints'] || []).each { |h| out << emit_hint(h) }

        if sub['intro']
          out << sub['intro'].strip
          out << ''
        end

        if sub['version_history']
          out << version_history_block(sub['version_history'])
          out << ''
        end

        (sub['hints'] || []).each { |h| out << emit_hint(h) }

        (sub['variables'] || []).each do |var|
          prop = props[var]
          unless prop
            warn "WARNING: variable #{var} listed in docs section tree but not found in schema properties or docs_only_variables"
            next
          end
          out << emit_variable(var, prop)
        end

        # subsections share the parent's heading level (siblings), matching upstream's flat structure.
        (sub['subsections'] || []).each do |nested|
          out << emit_subsection(nested, props, level: level)
        end

        out.join("\n")
      end
      private_class_method :emit_subsection

      def self.emit_variable(name, prop)
        out = []
        status = prop['x-status'] || 'active'
        badge = case status
                when 'removed'    then ' {{%removed%}}'
                when 'deprecated' then ' {{%deprecated%}}'
                else ''
                end

        explicit_anchor = prop['x-anchor']
        anchor_part =
          if explicit_anchor && !explicit_anchor.empty?
            " {##{explicit_anchor}}"
          elsif explicit_anchor == ''
            ''
          elsif status == 'removed'
            " {##{name.downcase}}"
          else
            ''
          end

        out << "#### `#{name}`#{badge}#{anchor_part}"
        out << ''

        body = []

        if status == 'removed' && !prop['x-suppress-removed-hint'] && !prop['description'].to_s.strip.empty?
          body << emit_hint({ 'style' => 'danger', 'body' => prop['description'].strip }).rstrip
          body << ''
        elsif !prop['description'].to_s.strip.empty?
          body << prop['description'].strip
          body << ''
        end

        if prop['x-show-default'] && prop.key?('default') && !prop['default'].nil?
          body << "**Default:** `#{prop['default']}`"
          body << ''
        end

        (prop['x-hints'] || []).each { |h| body << emit_hint(h).rstrip; body << '' }

        if prop['x-extra']
          body << prop['x-extra'].strip
          body << ''
        end

        if prop['x-version-history']&.any?
          body << version_history_block(prop['x-version-history'])
          body << ''
        end

        if prop.key?('x-example-value')
          body << "Example value: `#{prop['x-example-value']}`"
          body << ''
        end

        if prop['x-trailing']
          body << prop['x-trailing'].strip
          body << ''
        end

        out.concat(body)
        out.join("\n")
      end
      private_class_method :emit_variable

      def self.version_history_block(entries)
        lines = ['**Version history:**\\']
        entries.each_with_index do |entry, i|
          suffix = i == entries.length - 1 ? '' : '\\'
          lines << "#{entry['version']} - #{entry['change']}#{suffix}"
        end
        lines.join("\n")
      end
      private_class_method :version_history_block

      def self.emit_hint(hint)
        style = hint['style'] || 'info'
        body  = hint['body'].to_s.strip
        "{{< hint style=\"#{style}\" >}}\n#{body}\n{{</ hint >}}\n\n"
      end
      private_class_method :emit_hint

      def self.emit_page_ref(page)
        "{{< page-ref page=\"#{page}\" >}}\n\n"
      end
      private_class_method :emit_page_ref
    end
  end
end
