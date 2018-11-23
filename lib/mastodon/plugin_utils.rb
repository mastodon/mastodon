module PluginUtils
  def path_prefix(path = '')
    "#{Dir.pwd}/#{path}"
  end

  def relative_path_prefix(path = '')
    path_prefix(path).gsub(Rails.root.join('').to_s, '').delete_suffix('/').delete_prefix('/')
  end

  def files_in_directory(glob, ext)
    Dir.chdir(path_prefix) { Dir.glob("#{glob}/*.#{ext}").each { |path| yield path } }
  end

  def folders_in_directory(path)
    Dir.children(path_prefix(path)).each { |child| yield [relative_path_prefix(path), child].join('/') }
  end
end
