# Optional publish task for Rake

begin
require 'rake/contrib/sshpublisher'
require 'rake/contrib/rubyforgepublisher'

publisher = Rake::CompositePublisher.new
publisher.add Rake::RubyForgePublisher.new('builder', 'jimweirich')
publisher.add Rake::SshFilePublisher.new(
  'linode',
  'htdocs/software/builder',
  '.',
  'builder.blurb')

desc "Publish the Documentation to RubyForge."
task :publish => [:rdoc] do
  publisher.upload
end
rescue LoadError
end
