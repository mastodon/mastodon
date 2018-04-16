class FakeModel
  attr_accessor(
    :avatar_file_name,
    :avatar_file_size,
    :avatar_updated_at,
    :avatar_content_type,
    :avatar_fingerprint,
    :id
  )

  def errors
    @errors ||= []
  end

  def run_paperclip_callbacks name, *args
  end

  def valid?
    errors.empty?
  end

  def new_record?
    false
  end
end
