Gemojione.asset_path = '/emoji/'
Gemojione.use_svg = true

Gemojione.module_eval do
  # Downcase the file names
  # Always use .svg
  def self.image_url_for_name(name)
    emoji = index.find_by_name(name)
    "#{asset_host}#{ File.join(asset_path, emoji['unicode'].downcase) }.svg"
  end

  # Use emojione class instead of emoji
  # Add draggable
  # Remove width
  def self.image_tag_for_moji(moji)
    %Q{<img draggable="false" alt="#{moji}" class="emojione" src="#{ image_url_for_unicode_moji(moji) }">}
  end

  def self.emojify(moji)
    self.replace_named_moji_with_images(self.replace_unicode_moji_with_images(moji))
  end
end
