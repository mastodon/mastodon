# frozen_string_literal: true

namespace :branding do
  desc 'Generate necessary graphic assets for branding from source SVG files'
  task generate: :environment do
    Rake::Task['branding:generate_app_icons'].invoke
    Rake::Task['branding:generate_app_badge'].invoke
    Rake::Task['branding:generate_github_assets'].invoke
    Rake::Task['branding:generate_mailer_assets'].invoke
  end

  desc 'Generate PNG icons and logos for e-mail templates'
  task generate_mailer_assets: :environment do
    rsvg_convert = Terrapin::CommandLine.new('rsvg-convert', '-h :size --keep-aspect-ratio :input -o :output')
    output_dest  = Rails.root.join('app', 'javascript', 'images', 'mailer')

    # Displayed size is 64px, at 3x it's 192px
    Dir[Rails.root.join('app', 'javascript', 'images', 'icons', '*.svg')].each do |path|
      rsvg_convert.run(input: path, size: 192, output: output_dest.join("#{File.basename(path, '.svg')}.png"))
    end

    # Displayed size is 34px, at 3x it's 102px
    rsvg_convert.run(input: Rails.root.join('app', 'javascript', 'images', 'logo-symbol-wordmark.svg'), size: 102, output: output_dest.join('wordmark.png'))

    # Displayed size is 24px, at 3x it's 72px
    rsvg_convert.run(input: Rails.root.join('app', 'javascript', 'images', 'logo-symbol-icon.svg'), size: 72, output: output_dest.join('logo.png'))
  end

  desc 'Generate light/dark logotypes for GitHub'
  task generate_github_assets: :environment do
    rsvg_convert = Terrapin::CommandLine.new('rsvg-convert', '--stylesheet :stylesheet -h :size --keep-aspect-ratio :input -o :output')
    output_dest  = Rails.root.join('lib', 'assets')

    rsvg_convert.run(stylesheet: Rails.root.join('lib', 'assets', 'wordmark.dark.css'), input: Rails.root.join('app', 'javascript', 'images', 'logo-symbol-wordmark.svg'), size: 102, output: output_dest.join('wordmark.dark.png'))
    rsvg_convert.run(stylesheet: Rails.root.join('lib', 'assets', 'wordmark.light.css'), input: Rails.root.join('app', 'javascript', 'images', 'logo-symbol-wordmark.svg'), size: 102, output: output_dest.join('wordmark.light.png'))
  end

  desc 'Generate favicons and app icons from SVG source files'
  task generate_app_icons: :environment do
    favicon_source  = Rails.root.join('app', 'javascript', 'images', 'logo.svg')
    app_icon_source = Rails.root.join('app', 'javascript', 'images', 'app-icon.svg')
    output_dest     = Rails.root.join('app', 'javascript', 'icons')

    rsvg_convert = Terrapin::CommandLine.new('rsvg-convert', '-w :size -h :size --keep-aspect-ratio :input -o :output')
    convert = Terrapin::CommandLine.new('convert', ':input :output', environment: { 'MAGICK_CONFIGURE_PATH' => nil })

    favicon_sizes      = [16, 32, 48]
    apple_icon_sizes   = [57, 60, 72, 76, 114, 120, 144, 152, 167, 180, 1024]
    android_icon_sizes = [36, 48, 72, 96, 144, 192, 256, 384, 512]

    favicons = []

    favicon_sizes.each do |size|
      output_path = output_dest.join("favicon-#{size}x#{size}.png")
      favicons << output_path
      rsvg_convert.run(size: size, input: favicon_source, output: output_path)
    end

    convert.run(input: favicons, output: Rails.public_path.join('favicon.ico'))

    apple_icon_sizes.each do |size|
      rsvg_convert.run(size: size, input: app_icon_source, output: output_dest.join("apple-touch-icon-#{size}x#{size}.png"))
    end

    android_icon_sizes.each do |size|
      rsvg_convert.run(size: size, input: app_icon_source, output: output_dest.join("android-chrome-#{size}x#{size}.png"))
    end
  end

  desc 'Generate badge icon from SVG source files'
  task generate_app_badge: :environment do
    rsvg_convert = Terrapin::CommandLine.new('rsvg-convert', '--stylesheet :stylesheet -w :size -h :size --keep-aspect-ratio :input -o :output')
    badge_source = Rails.root.join('app', 'javascript', 'images', 'logo-symbol-icon.svg')
    output_dest  = Rails.public_path
    stylesheet   = Rails.root.join('lib', 'assets', 'wordmark.light.css')

    rsvg_convert.run(stylesheet: stylesheet, input: badge_source, size: 192, output: output_dest.join('badge.png'))
  end
end
