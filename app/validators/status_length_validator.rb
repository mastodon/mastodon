class StatusLengthValidator < ActiveModel::Validator
  def validate(status)
    if status.local? && !status.reblog?
      combinedText = status.text
      if (status.spoiler? && status.spoiler_text.present?)
        combinedText = status.spoiler_text + "\n" + status.text
      end

      maxChars = 500
      unless combinedText.length <= maxChars
        status.errors[:text] << "is too long (maximum is #{maxChars})"
      end
    end
  end
end