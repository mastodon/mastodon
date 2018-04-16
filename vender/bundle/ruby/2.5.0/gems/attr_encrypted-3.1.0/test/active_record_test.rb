require_relative 'test_helper'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

def create_tables
  ActiveRecord::Schema.define(version: 1) do
    self.verbose = false
    create_table :people do |t|
      t.string   :encrypted_email
      t.string   :password
      t.string   :encrypted_credentials
      t.binary   :salt
      t.binary   :key_iv
      t.string   :encrypted_email_salt
      t.string   :encrypted_credentials_salt
      t.string   :encrypted_email_iv
      t.string   :encrypted_credentials_iv
    end
    create_table :accounts do |t|
      t.string :encrypted_password
      t.string :encrypted_password_iv
      t.string :encrypted_password_salt
      t.string :key
    end
    create_table :users do |t|
      t.string :login
      t.string :encrypted_password
      t.string :encrypted_password_iv
      t.boolean :is_admin
    end
    create_table :prime_ministers do |t|
      t.string :encrypted_name
      t.string :encrypted_name_iv
    end
    create_table :addresses do |t|
      t.binary :encrypted_street
      t.binary :encrypted_street_iv
      t.binary :encrypted_zipcode
      t.string :mode
    end
  end
end

ActiveRecord::MissingAttributeError = ActiveModel::MissingAttributeError unless defined?(ActiveRecord::MissingAttributeError)

if ::ActiveRecord::VERSION::STRING > "4.0"
  module Rack
    module Test
      class UploadedFile; end
    end
  end

  require 'action_controller/metal/strong_parameters'
end

class Person < ActiveRecord::Base
  self.attr_encrypted_options[:mode] = :per_attribute_iv_and_salt
  attr_encrypted :email, key: SECRET_KEY
  attr_encrypted :credentials, key: Proc.new { |user| Encryptor.encrypt(value: user.salt, key: SECRET_KEY, iv: user.key_iv) }, marshal: true

  after_initialize :initialize_salt_and_credentials

  protected

  def initialize_salt_and_credentials
    self.key_iv ||= SecureRandom.random_bytes(12)
    self.salt ||= Digest::SHA256.hexdigest((Time.now.to_i * rand(1000)).to_s)[0..15]
    self.credentials ||= { username: 'example', password: 'test' }
  end
end

class PersonWithValidation < Person
  validates_presence_of :email
end

class PersonWithProcMode < Person
  attr_encrypted :email,       key: SECRET_KEY, mode: Proc.new { :per_attribute_iv_and_salt }
  attr_encrypted :credentials, key: SECRET_KEY, mode: Proc.new { :single_iv_and_salt }, insecure_mode: true
end

class Account < ActiveRecord::Base
  ACCOUNT_ENCRYPTION_KEY = SecureRandom.urlsafe_base64(24)
  attr_encrypted :password, key: :password_encryption_key

  def encrypting?(attr)
    encrypted_attributes[attr][:operation] == :encrypting
  end

  def password_encryption_key
    if encrypting?(:password)
      self.key = ACCOUNT_ENCRYPTION_KEY
    else
      self.key
    end
  end
end

class PersonWithSerialization < ActiveRecord::Base
  self.table_name = 'people'
  attr_encrypted :email, key: SECRET_KEY
  serialize :password
end

class UserWithProtectedAttribute < ActiveRecord::Base
  self.table_name = 'users'
  attr_encrypted :password, key: SECRET_KEY
  attr_protected :is_admin if ::ActiveRecord::VERSION::STRING < "4.0"
end

class PersonUsingAlias < ActiveRecord::Base
  self.table_name = 'people'
  attr_encryptor :email, key: SECRET_KEY
end

class PrimeMinister < ActiveRecord::Base
  attr_encrypted :name, marshal: true, key: SECRET_KEY
end

class Address < ActiveRecord::Base
  self.attr_encrypted_options[:marshal] = false
  self.attr_encrypted_options[:encode] = false
  attr_encrypted :street, encode_iv: false, key: SECRET_KEY
  attr_encrypted :zipcode, key: SECRET_KEY, mode: Proc.new { |address| address.mode.to_sym }, insecure_mode: true
end

class ActiveRecordTest < Minitest::Test

  def setup
    drop_all_tables
    create_tables
  end

  def test_should_encrypt_email
    @person = Person.create(email: 'test@example.com')
    refute_nil @person.encrypted_email
    refute_equal @person.email, @person.encrypted_email
    assert_equal @person.email, Person.first.email
  end

  def test_should_marshal_and_encrypt_credentials
    @person = Person.create
    refute_nil @person.encrypted_credentials
    refute_equal @person.credentials, @person.encrypted_credentials
    assert_equal @person.credentials, Person.first.credentials
  end

  def test_should_encode_by_default
    assert Person.attr_encrypted_options[:encode]
  end

  def test_should_validate_presence_of_email
    @person = PersonWithValidation.new
    assert !@person.valid?
    assert !@person.errors[:email].empty? || @person.errors.on(:email)
  end

  def test_should_encrypt_decrypt_with_iv
    @person = Person.create(email: 'test@example.com')
    @person2 = Person.find(@person.id)
    refute_nil @person2.encrypted_email_iv
    assert_equal 'test@example.com', @person2.email
  end

  def test_should_ensure_attributes_can_be_deserialized
    @person = PersonWithSerialization.new(email: 'test@example.com', password: %w(an array of strings))
    @person.save
    assert_equal @person.password, %w(an array of strings)
  end

  def test_should_create_an_account_regardless_of_arguments_order
    Account.create!(key: SECRET_KEY, password: "password")
    Account.create!(password: "password" , key: SECRET_KEY)
  end

  def test_should_set_attributes_regardless_of_arguments_order
    # minitest does not implement `assert_nothing_raised` https://github.com/seattlerb/minitest/issues/112
    Account.new.attributes = { password: "password", key: SECRET_KEY }
  end

  def test_should_create_changed_predicate
    person = Person.create!(email: 'test@example.com')
    refute person.email_changed?
    person.email = 'test@example.com'
    refute person.email_changed?
    person.email = nil
    assert person.email_changed?
    person.email = 'test2@example.com'
    assert person.email_changed?
  end

  def test_should_create_was_predicate
    original_email = 'test@example.com'
    person = Person.create!(email: original_email)
    assert_equal original_email, person.email_was
    person.email = 'test2@example.com'
    assert_equal original_email, person.email_was
    old_pm_name = "Winston Churchill"
    pm = PrimeMinister.create!(name: old_pm_name)
    assert_equal old_pm_name, pm.name_was
    old_zipcode = "90210"
    address = Address.create!(zipcode: old_zipcode, mode: "single_iv_and_salt")
    assert_equal old_zipcode, address.zipcode_was
  end

  def test_attribute_was_works_when_options_for_old_encrypted_value_are_different_than_options_for_new_encrypted_value
    pw = 'password'
    crypto_key = SecureRandom.urlsafe_base64(24)
    old_iv = SecureRandom.random_bytes(12)
    account = Account.create
    encrypted_value = Encryptor.encrypt(value: pw, iv: old_iv, key: crypto_key)
    Account.where(id: account.id).update_all(key: crypto_key, encrypted_password_iv: [old_iv].pack('m'), encrypted_password: [encrypted_value].pack('m'))
    account = Account.find(account.id)
    assert_equal pw, account.password
    account.password = pw.reverse
    assert_equal pw, account.password_was
    account.save
    account.reload
    assert_equal Account::ACCOUNT_ENCRYPTION_KEY, account.key
    assert_equal pw.reverse, account.password
  end

  if ::ActiveRecord::VERSION::STRING > "4.0"
    def test_should_assign_attributes
      @user = UserWithProtectedAttribute.new(login: 'login', is_admin: false)
      @user.attributes = ActionController::Parameters.new(login: 'modified', is_admin: true).permit(:login)
      assert_equal 'modified', @user.login
    end

    def test_should_not_assign_protected_attributes
      @user = UserWithProtectedAttribute.new(login: 'login', is_admin: false)
      @user.attributes = ActionController::Parameters.new(login: 'modified', is_admin: true).permit(:login)
      assert !@user.is_admin?
    end

    def test_should_raise_exception_if_not_permitted
      @user = UserWithProtectedAttribute.new(login: 'login', is_admin: false)
      assert_raises ActiveModel::ForbiddenAttributesError do
        @user.attributes = ActionController::Parameters.new(login: 'modified', is_admin: true)
      end
    end

    def test_should_raise_exception_on_init_if_not_permitted
      assert_raises ActiveModel::ForbiddenAttributesError do
        @user = UserWithProtectedAttribute.new ActionController::Parameters.new(login: 'modified', is_admin: true)
      end
    end
  else
    def test_should_assign_attributes
      @user = UserWithProtectedAttribute.new(login: 'login', is_admin: false)
      @user.attributes = { login: 'modified', is_admin: true }
      assert_equal 'modified', @user.login
    end

    def test_should_not_assign_protected_attributes
      @user = UserWithProtectedAttribute.new(login: 'login', is_admin: false)
      @user.attributes = { login: 'modified', is_admin: true }
      assert !@user.is_admin?
    end

    def test_should_assign_protected_attributes
      @user = UserWithProtectedAttribute.new(login: 'login', is_admin: false)
      if ::ActiveRecord::VERSION::STRING > "3.1"
        @user.send(:assign_attributes, { login: 'modified', is_admin: true }, without_protection: true)
      else
        @user.send(:attributes=, { login: 'modified', is_admin: true }, false)
      end
      assert @user.is_admin?
    end
  end

  def test_should_allow_assignment_of_nil_attributes
    @person = Person.new
    assert_nil(@person.attributes = nil)
  end

  def test_should_allow_proc_based_mode
    @person = PersonWithProcMode.create(email: 'test@example.com', credentials: 'password123')

    # Email is :per_attribute_iv_and_salt
    assert_equal @person.class.encrypted_attributes[:email][:mode].class, Proc
    assert_equal @person.class.encrypted_attributes[:email][:mode].call, :per_attribute_iv_and_salt
    refute_nil @person.encrypted_email_salt
    refute_nil @person.encrypted_email_iv

    # Credentials is :single_iv_and_salt
    assert_equal @person.class.encrypted_attributes[:credentials][:mode].class, Proc
    assert_equal @person.class.encrypted_attributes[:credentials][:mode].call, :single_iv_and_salt
    assert_nil @person.encrypted_credentials_salt
    assert_nil @person.encrypted_credentials_iv
  end

  if ::ActiveRecord::VERSION::STRING > "3.1"
    def test_should_allow_assign_attributes_with_nil
      @person = Person.new
      assert_nil(@person.assign_attributes nil)
    end
  end

  def test_that_alias_encrypts_column
    user = PersonUsingAlias.new
    user.email = 'test@example.com'
    user.save

    refute_nil user.encrypted_email
    refute_equal user.email, user.encrypted_email
    assert_equal user.email, PersonUsingAlias.first.email
  end

  # See https://github.com/attr-encrypted/attr_encrypted/issues/68
  def test_should_invalidate_virtual_attributes_on_reload
    old_pm_name = 'Winston Churchill'
    new_pm_name = 'Neville Chamberlain'
    pm = PrimeMinister.create!(name: old_pm_name)
    assert_equal old_pm_name, pm.name
    pm.name = new_pm_name
    assert_equal new_pm_name, pm.name

    result = pm.reload
    assert_equal pm, result
    assert_equal old_pm_name, pm.name
  end

  def test_should_save_encrypted_data_as_binary
    street = '123 Elm'
    address = Address.create!(street: street)
    refute_equal address.encrypted_street, street
    assert_equal Address.first.street, street
  end

  def test_should_evaluate_proc_based_mode
    street = '123 Elm'
    zipcode = '12345'
    address = Address.create(street: street, zipcode: zipcode, mode: :single_iv_and_salt)
    address.reload
    refute_equal address.encrypted_zipcode, zipcode
    assert_equal address.zipcode, zipcode
  end
end
