# frozen_string_literal: true

def download_material_icon(icon, weight: 400, filled: false, size: 20)
  url_template = Addressable::Template.new('https://fonts.gstatic.com/s/i/short-term/release/materialsymbolsoutlined/{icon}/{axes}/{size}px.svg')

  variant = filled ? '-fill' : ''

  axes = []
  axes << "wght#{weight}" if weight != 400
  axes << 'fill1' if filled
  axes = axes.join.presence || 'default'

  url = url_template.expand(icon: icon, axes: axes, size: size).to_s
  path = Rails.root.join('app', 'javascript', 'material-icons', "#{weight}-#{size}px", "#{icon}#{variant}.svg")
  FileUtils.mkdir_p(File.dirname(path))

  File.write(path, HTTP.get(url).to_s)
end

def find_used_icons
  icons_by_weight_and_size = {}

  Rails.root.glob('app/javascript/**/*.*s*').map do |path|
    File.open(path, 'r') do |file|
      pattern = %r{\Aimport .* from '@/material-icons/(?<weight>[0-9]+)-(?<size>[0-9]+)px/(?<icon>[^-]*)(?<fill>-fill)?.svg\?react';}
      file.each_line do |line|
        match = pattern.match(line)
        next if match.blank?

        weight = match['weight'].to_i
        size = match['size'].to_i

        icons_by_weight_and_size[weight] ||= {}
        icons_by_weight_and_size[weight][size] ||= Set.new

        icons_by_weight_and_size[weight][size] << match['icon']
      end
    end
  end

  icons_by_weight_and_size
end

namespace :icons do
  desc 'Download used Material Symbols icons'
  task download: :environment do
    find_used_icons.each do |weight, icons_by_size|
      icons_by_size.each do |size, icons|
        icons.each do |icon|
          download_material_icon(icon, weight: weight, size: size)
          download_material_icon(icon, weight: weight, size: size, filled: true)
        end
      end
    end
  end
end
