class ProcessFeedService
  include ApplicationHelper

  def call(body, account)
    xml = Nokogiri::XML(body)

    xml.xpath('//xmlns:entry').each do |entry|
      next unless [:note, :comment, :activity].includes? object_type(entry)

      status = Status.find_by(uri: activity_id(entry))

      next unless status.nil?

      status = Status.new(uri: activity_id(entry), account: account, text: content(entry), created_at: published(entry), updated_at: updated(entry))

      if object_type(entry) == :comment
        add_reply!(entry, status)
      elsif verb(entry) == :share
        add_reblog!(entry, status)
      else
        add_post!(entry, status)
      end
    end
  end

  private

  def add_post!(entry, status)
    status.save!
  end

  def add_reblog!(entry, status)
    status.reblog = find_original_status(entry, target_id(entry))
  end

  def add_reply!(entry, status)
    status.thread = find_original_status(entry, thread_id(entry))
  end

  def find_original_status(xml, id)
    return nil if id.nil?

    if local_id?(id)
      Status.find(unique_tag_to_local_id(id, 'Status'))
    else
      status = Status.find_by(uri: id)

      if status.nil?
        status = fetch_remote_status(xml, id)
      end

      status
    end
  end

  def fetch_remote_status(xml, id)
    # todo
  end

  def local_id?(id)
    id.start_with?("tag:#{LOCAL_DOMAIN}")
  end

  def published(xml)
    xml.at_xpath('./xmlns:published').content
  end

  def updated(xml)
    xml.at_xpath('./xmlns:updated').content
  end

  def content(xml)
    xml.at_xpath('./xmlns:content').content
  end

  def thread_id(xml)
    xml.at_xpath('./thr:in-reply-to-id').attribute('ref').value
  rescue
    nil
  end

  def target_id(xml)
    xml.at_xpath('./activity:object/xmlns:id').content
  rescue
    nil
  end

  def activity_id(xml)
    entry.at_xpath('./xmlns:id').content
  end

  def object_type(xml)
    xml.at_xpath('./activity:object-type').content.gsub('http://activitystrea.ms/schema/1.0/', '').to_sym
  rescue
    :note
  end

  def verb(xml)
    xml.at_xpath('./activity:verb').content.gsub('http://activitystrea.ms/schema/1.0/', '').to_sym
  rescue
    :post
  end
end
