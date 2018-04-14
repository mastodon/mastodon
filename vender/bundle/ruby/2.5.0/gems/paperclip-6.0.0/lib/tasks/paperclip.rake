require 'paperclip/attachment_registry'

module Paperclip
  module Task
    def self.obtain_class
      class_name = ENV['CLASS'] || ENV['class']
      raise "Must specify CLASS" unless class_name
      class_name
    end

    def self.obtain_attachments(klass)
      klass = Paperclip.class_for(klass.to_s)
      name = ENV['ATTACHMENT'] || ENV['attachment']

      attachment_names = Paperclip::AttachmentRegistry.names_for(klass)

      if attachment_names.empty?
        raise "Class #{klass.name} has no attachments specified"
      end

      if name.present? && attachment_names.map(&:to_s).include?(name.to_s)
        [ name ]
      else
        attachment_names
      end
    end

    def self.log_error(error)
      $stderr.puts error
    end
  end
end

namespace :paperclip do
  desc "Refreshes both metadata and thumbnails."
  task :refresh => ["paperclip:refresh:metadata", "paperclip:refresh:thumbnails"]

  namespace :refresh do
    desc "Regenerates thumbnails for a given CLASS (and optional ATTACHMENT and STYLES splitted by comma)."
    task :thumbnails => :environment do
      klass = Paperclip::Task.obtain_class
      names = Paperclip::Task.obtain_attachments(klass)
      styles = (ENV['STYLES'] || ENV['styles'] || '').split(',').map(&:to_sym)
      names.each do |name|
        Paperclip.each_instance_with_attachment(klass, name) do |instance|
          attachment = instance.send(name)
          begin
            attachment.reprocess!(*styles)
          rescue StandardError => e
            Paperclip::Task.log_error("exception while processing #{klass} ID #{instance.id}:")
            Paperclip::Task.log_error(" " + e.message + "\n")
          end
          unless instance.errors.blank?
            Paperclip::Task.log_error("errors while processing #{klass} ID #{instance.id}:")
            Paperclip::Task.log_error(" " + instance.errors.full_messages.join("\n ") + "\n")
          end
        end
      end
    end

    desc "Regenerates content_type/size metadata for a given CLASS (and optional ATTACHMENT)."
    task :metadata => :environment do
      klass = Paperclip::Task.obtain_class
      names = Paperclip::Task.obtain_attachments(klass)
      names.each do |name|
        Paperclip.each_instance_with_attachment(klass, name) do |instance|
          attachment = instance.send(name)
          if file = Paperclip.io_adapters.for(attachment, attachment.options[:adapter_options])
            instance.send("#{name}_file_name=", instance.send("#{name}_file_name").strip)
            instance.send("#{name}_content_type=", file.content_type.to_s.strip)
            instance.send("#{name}_file_size=", file.size) if instance.respond_to?("#{name}_file_size")
            instance.save(:validate => false)
          else
            true
          end
        end
      end
    end

    desc "Regenerates missing thumbnail styles for all classes using Paperclip."
    task :missing_styles => :environment do
      Rails.application.eager_load!
      Paperclip.missing_attachments_styles.each do |klass, attachment_definitions|
        attachment_definitions.each do |attachment_name, missing_styles|
          puts "Regenerating #{klass} -> #{attachment_name} -> #{missing_styles.inspect}"
          ENV['CLASS'] = klass.to_s
          ENV['ATTACHMENT'] = attachment_name.to_s
          ENV['STYLES'] = missing_styles.join(',')
          Rake::Task['paperclip:refresh:thumbnails'].execute
        end
      end
      Paperclip.save_current_attachments_styles!
    end

    desc "Regenerates fingerprints for a given CLASS (and optional ATTACHMENT). Useful when changing digest."
    task :fingerprints => :environment do
      klass = Paperclip::Task.obtain_class
      names = Paperclip::Task.obtain_attachments(klass)
      names.each do |name|
        Paperclip.each_instance_with_attachment(klass, name) do |instance|
          attachment = instance.send(name)
          attachment.assign(attachment)
          instance.save(:validate => false)
        end
      end
    end
  end

  desc "Cleans out invalid attachments. Useful after you've added new validations."
  task :clean => :environment do
    klass = Paperclip::Task.obtain_class
    names = Paperclip::Task.obtain_attachments(klass)
    names.each do |name|
      Paperclip.each_instance_with_attachment(klass, name) do |instance|
        unless instance.valid?
          attributes = %w(file_size file_name content_type).map{ |suffix| "#{name}_#{suffix}".to_sym }
          if attributes.any?{ |attribute| instance.errors[attribute].present? }
            instance.send("#{name}=", nil)
            instance.save(:validate => false)
          end
        end
      end
    end
  end

  desc "find missing attachments. Useful to know which attachments are broken"
  task :find_broken_attachments => :environment do
    klass = Paperclip::Task.obtain_class
    names = Paperclip::Task.obtain_attachments(klass)
    names.each do |name|
      Paperclip.each_instance_with_attachment(klass, name) do |instance|
        attachment = instance.send(name)
        if attachment.exists?
          print "."
        else
          Paperclip::Task.log_error("#{instance.class}##{attachment.name}, #{instance.id}, #{attachment.url}")
        end
      end
    end
  end
end
