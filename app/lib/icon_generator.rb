# frozen_string_literal: true

module IconGenerator
  extend self

  def generate_favicons(source_path, output_dest, sizes)
    favicons = generate_icons(source_path, output_dest, sizes, 'favicon')

    convert.run(input: favicons, output: Rails.public_path.join('favicon.ico'))
  end

  def generate_app_icons(source_path, output_dest, sizes, prefix)
    generate_icons(source_path, output_dest, sizes, prefix)
  end

  private

  def generate_icons(source_path, output_dest, sizes, prefix)
    icon_paths = []
    sizes.each do |size|
      output_path = output_dest.join("#{prefix}-#{size}x#{size}.png")
      icon_paths << output_path
      rsvg_convert.run(size: size, input: source_path, output: output_path)
    end
    icon_paths
  end

  def rsvg_convert
    @rsvg_convert ||= Terrapin::CommandLine.new('rsvg-convert', '-w :size -h :size --keep-aspect-ratio :input -o :output')
  end

  def convert
    @convert ||= Terrapin::CommandLine.new('convert', ':input :output', environment: { 'MAGICK_CONFIGURE_PATH' => nil })
  end
end
