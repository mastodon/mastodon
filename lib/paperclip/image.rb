# frozen_string_literal: true

class Paperclip::Image < Paperclip::Thumbnail
  def make(*)
    exiv2_p_out, exiv2_p_err, exiv2_p_status = Open3.capture3(
      'exiv2',
      '-PXkyt',
      '-g^Xmp\.GPano\.',
      @file.path
    )

    destination = super

    begin
      unless exiv2_p_status.success?
        Rails.logger.debug "exiv2 -PXkyt #{@file.path} exited with #{exiv2_p_status}:"
        Rails.logger.debug exiv2_p_err

        return destination
      end

      commands = convert_metadata(exiv2_p_out, destination)
      return destination if commands.nil?

      _, exiv2_m_err, exiv2_m_status = Open3.capture3(
        'exiv2',
        '-m-',
        destination.path,
        stdin_data: commands,
        err: [:child, :out]
      )

      unless exiv2_m_status.success?
        Rails.logger.debug "exiv2 -m- #{destination.path} exited with #{exiv2_m_status}:"
        Rails.logger.debug exiv2_m_err
      end

      destination
    rescue
      destination.unlink
      raise
    end
  end

  private

  def convert_metadata(metadata, destination)
    destination_geometry = Paperclip::Geometry.from_file destination
    width_scale = nil
    height_scale = nil

    lines = metadata.each_line.map do |line|
      if line.start_with? 'Xmp.GPano.CroppedAreaImageWidthPixels '
        edit_integer line do |width|
          width_scale = destination_geometry.width / width
          destination_geometry.width
        end
      elsif line.start_with? 'Xmp.GPano.CroppedAreaImageHeightPixels '
        edit_integer line do |height|
          height_scale = destination_geometry.height / height
          destination_geometry.height
        end
      else
        line
      end
    end

    return nil if width_scale.nil? || height_scale.nil?

    lines.map! do |line|
      if line.start_with? 'Xmp.GPano.FullPanoWidthPixels '
        edit_integer(line) { |width| width * width_scale }
      elsif line.start_with? 'Xmp.GPano.FullPanoHeightPixels '
        edit_integer(line) { |height| height * height_scale }
      elsif line.start_with? 'Xmp.GPano.CroppedAreaLeftPixels '
        edit_integer(line) { |left| left * width_scale }
      elsif line.start_with? 'Xmp.GPano.CroppedAreaTopPixels '
        edit_integer(line) { |top| top * height_scale }
      else
        line
      end
    end

    lines.each { |line| line.prepend 'set ' }.join
  end

  def edit_integer(line)
    words = line.split(/\s+/)
    words[2] = (yield words[2].to_i).to_i.to_s
    words.join(' ') + "\n"
  end
end
