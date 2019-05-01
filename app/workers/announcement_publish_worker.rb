class AnnouncementPublishWorker
  include Sidekiq::Worker

  def perform
    @announcements = Announcement.all
    resources = ActiveModelSerializers::SerializableResource.new(@announcements, each_serializer: REST::AnnouncementSerializer)
    Redis.current.publish('commands', Oj.dump(event: 'announcements', payload: resources))
  end
end
