# frozen_string_literal: true

class ProcessLinksService < BaseService
  include Payloadable

  # Scan status for links to ActivityPub objects and attach them to statuses
  # @param [Status] status
  def call(status)
    return unless status.local?

    @status = status
    @previous_objects = @status.tagged_objects.includes(:object).to_a
    @current_objects  = []

    Status.transaction do
      scan_text!
      assign_tagged_objects!
    end
  end

  private

  def scan_text!
    urls = @status.text.scan(FetchLinkCardService::URL_PATTERN).map { |array| Addressable::URI.parse(array[1]).normalize }

    urls.each do |url|
      # We only support `FeaturedCollection` at this time

      # TODO: We probably want to resolve unknown objects at authoring time
      object = ActivityPub::TagManager.instance.uri_to_resource(url.to_s, Collection)
      next if object.nil?

      tagged_object = @previous_objects.find { |x| x.object == object || x.uri == url }
      tagged_object ||= @current_objects.find { |x| x.object == object || x.uri == url }
      tagged_object ||= @status.tagged_objects.new(object: object, ap_type: 'FeaturedCollection', uri: ActivityPub::TagManager.instance.uri_for(object))

      @current_objects << tagged_object
    end
  end

  def assign_tagged_objects!
    return unless @status.persisted?

    @current_objects.each do |object|
      object.save if object.new_record?
    end

    # If previous objects are no longer contained in the text, remove them to lighten the database
    removed_objects = @previous_objects - @current_objects

    TaggedObject.where(id: removed_objects.map(&:id)).delete_all unless removed_objects.empty?
  end
end
