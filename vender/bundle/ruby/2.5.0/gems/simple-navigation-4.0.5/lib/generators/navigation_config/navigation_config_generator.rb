class NavigationConfigGenerator < Rails::Generators::Base
  def self.source_root
    @source_root ||= begin
      tpl_dir = %w[.. .. .. .. generators navigation_config templates]
      tpl_dir_path = File.join(tpl_dir)
      File.expand_path(tpl_dir_path, __FILE__)
    end
  end

  desc 'Creates a template config file for the simple-navigation plugin. ' \
       'You will find the generated file in config/navigation.rb.'
  def navigation_config
    copy_file('config/navigation.rb', 'config/navigation.rb')
    readme_path = File.join(%w[.. .. .. .. README.md])
    say File.read(File.expand_path(readme_path, __FILE__))
  end
end
