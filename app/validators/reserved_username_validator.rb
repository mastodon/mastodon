class ReservedUsernameValidator < ActiveModel::Validator
  RESERVED_USERNAMES = begin
    names = YAML.load_file(Rails.root.join('config', 'reserved_username.yml'))
    names.delete('admin') if Rails.env.development?
    names
  end

  def validate(record)
    record.errors.add(:username, I18n.t('users.reserved_username')) if reserved_name?(record.username)
  end

  private

  def reserved_name?(name)
    RESERVED_USERNAMES.include?(name)
  end
end
