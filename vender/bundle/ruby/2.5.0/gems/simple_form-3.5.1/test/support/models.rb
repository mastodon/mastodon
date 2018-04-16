# frozen_string_literal: true
Association = Struct.new(:klass, :name, :macro, :scope, :options)

Column = Struct.new(:name, :type, :limit) do
end

Relation = Struct.new(:records) do
  delegate :each, to: :records

  def where(conditions = nil)
    self.class.new conditions ? [records.first] : records
  end

  def order(conditions = nil)
    self.class.new conditions ? records.last : records
  end

  alias_method :to_a,   :records
  alias_method :to_ary, :records
end

Decorator = Struct.new(:object) do
  def to_model
    object
  end
end

Picture = Struct.new(:id, :name) do
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def self.where(conditions = nil)
    if conditions.is_a?(Hash) && conditions[:name]
      all.to_a.last
    else
      all
    end
  end

  def self.all
    Relation.new((1..3).map { |i| new(i, "#{name} #{i}") })
  end
end

Company = Struct.new(:id, :name) do
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  class << self
    delegate :order, :where, to: :_relation
  end

  def self._relation
    all
  end

  def self.all
    Relation.new((1..3).map { |i| new(i, "#{name} #{i}") })
  end

  def persisted?
    true
  end
end

Friend = Struct.new(:id, :name) do
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def self.all
    (1..3).map { |i| new(i, "#{name} #{i}") }
  end

  def persisted?
    true
  end
end

class Tag < Company; end

TagGroup = Struct.new(:id, :name, :tags)

class User
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :id, :name, :company, :company_id, :time_zone, :active, :age,
    :description, :created_at, :updated_at, :credit_limit, :password, :url,
    :delivery_time, :born_at, :special_company_id, :country, :tags, :tag_ids,
    :avatar, :home_picture, :email, :status, :residence_country, :phone_number,
    :post_count, :lock_version, :amount, :attempts, :action, :credit_card, :gender,
    :extra_special_company_id, :pictures, :picture_ids, :special_pictures,
    :special_picture_ids, :uuid, :friends, :friend_ids, :special_tags, :special_tag_ids

  def self.build(extra_attributes = {})
    attributes = {
      id: 1,
      name: 'New in SimpleForm!',
      description: 'Hello!',
      created_at: Time.now
    }.merge! extra_attributes

    new attributes
  end

  def initialize(options = {})
    @new_record = false
    options.each do |key, value|
      send("#{key}=", value)
    end if options
  end

  def new_record!
    @new_record = true
  end

  def persisted?
    !@new_record
  end

  def company_attributes=(*)
  end

  def tags_attributes=(*)
  end

  def column_for_attribute(attribute)
    column_type, limit = case attribute.to_sym
      when :name, :status, :password then [:string, 100]
      when :description   then [:text, 200]
      when :age           then :integer
      when :credit_limit  then [:decimal, 15]
      when :active        then :boolean
      when :born_at       then :date
      when :delivery_time then :time
      when :created_at    then :datetime
      when :updated_at    then :timestamp
      when :lock_version  then :integer
      when :home_picture  then :string
      when :amount        then :integer
      when :attempts      then :integer
      when :action        then :string
      when :credit_card   then :string
      when :uuid          then :uuid
    end
    Column.new(attribute, column_type, limit)
  end

  begin
    require 'active_model/type'
    begin
      ActiveModel::Type.lookup(:text)
    rescue ArgumentError        # :text is no longer an ActiveModel::Type
      # But we don't want our tests to depend on ActiveRecord
      class ::ActiveModel::Type::Text < ActiveModel::Type::String
        def type; :text; end
      end
      ActiveModel::Type.register(:text, ActiveModel::Type::Text)
    end
    def type_for_attribute(attribute)
      column_type, limit = case attribute
        when 'name', 'status', 'password' then [:string, 100]
        when 'description'   then [:text, 200]
        when 'age'           then :integer
        when 'credit_limit'  then [:decimal, 15]
        when 'active'        then :boolean
        when 'born_at'       then :date
        when 'delivery_time' then :time
        when 'created_at'    then :datetime
        when 'updated_at'    then :datetime
        when 'lock_version'  then :integer
        when 'home_picture'  then :string
        when 'amount'        then :integer
        when 'attempts'      then :integer
        when 'action'        then :string
        when 'credit_card'   then :string
        when 'uuid'          then :string
      end

      ActiveModel::Type.lookup(column_type, limit: limit)
    end
  rescue LoadError
  end

  def has_attribute?(attribute)
    case attribute.to_sym
      when :name, :status, :password, :description, :age,
        :credit_limit, :active, :born_at, :delivery_time,
        :created_at, :updated_at, :lock_version, :home_picture,
        :amount, :attempts, :action, :credit_card, :uuid then true
      else false
    end
  end

  def self.human_attribute_name(attribute, options = {})
    case attribute
      when 'name'
        'Super User Name!'
      when 'description'
        'User Description!'
      when 'company'
        'Company Human Name!'
      else
        attribute.to_s.humanize
    end
  end

  def self.reflect_on_association(association)
    case association
      when :company
        Association.new(Company, association, :belongs_to, nil, {})
      when :tags
        Association.new(Tag, association, :has_many, nil, {})
      when :special_tags
        Association.new(Tag, association, :has_many, ->(user) { where(id: user.id) }, {})
      when :first_company
        Association.new(Company, association, :has_one, nil, {})
      when :special_company
        Association.new(Company, association, :belongs_to, nil, conditions: { id: 1 })
      when :extra_special_company
        Association.new(Company, association, :belongs_to, nil, conditions: proc { { id: self.id } })
      when :pictures
        Association.new(Picture, association, :has_many, nil, {})
      when :special_pictures
        Association.new(Picture, association, :has_many, proc { where(name: self.name) }, {})
      when :friends
        Association.new(Friend, association, :has_many, nil, {})
    end
  end

  def errors
    @errors ||= begin
      errors = ActiveModel::Errors.new(self)
      errors.add(:name, "cannot be blank")
      errors.add(:description, 'must be longer than 15 characters')
      errors.add(:age, 'is not a number')
      errors.add(:age, 'must be greater than 18')
      errors.add(:company, 'company must be present')
      errors.add(:company_id, 'must be valid')
      errors
    end
  end

  def self.readonly_attributes
    ["credit_card"]
  end
end

class ValidatingUser < User
  include ActiveModel::Validations
  validates :name, presence: true
  validates :company, presence: true
  validates :age, presence: true, if: proc { |user| user.name }
  validates :amount, presence: true, unless: proc { |user| user.age }

  validates :action,            presence: true, on: :create
  validates :credit_limit,      presence: true, on: :save
  validates :phone_number,      presence: true, on: :update

  validates_numericality_of :age,
    greater_than_or_equal_to: 18,
    less_than_or_equal_to: 99,
    only_integer: true
  validates_numericality_of :amount,
    greater_than: :min_amount,
    less_than: :max_amount,
    only_integer: true
  validates_numericality_of :attempts,
    greater_than_or_equal_to: :min_attempts,
    less_than_or_equal_to: :max_attempts,
    only_integer: true
  validates_length_of :name, maximum: 25, minimum: 5
  validates_length_of :description, in: 15..50
  if ActionPack::VERSION::STRING < '5'
    validates_length_of :action, maximum: 10, tokenizer: ->(str) { str.scan(/\w+/) }
  end
  validates_length_of :home_picture, is: 12

  def min_amount
    10
  end

  def max_amount
    100
  end

  def min_attempts
    1
  end

  def max_attempts
    100
  end
end

class OtherValidatingUser < User
  include ActiveModel::Validations
  validates_numericality_of :age,
    greater_than: 17,
    less_than: 100,
    only_integer: true
  validates_numericality_of :amount,
    greater_than: proc { |user| user.age },
    less_than: proc { |user| user.age + 100 },
    only_integer: true
  validates_numericality_of :attempts,
    greater_than_or_equal_to: proc { |user| user.age },
    less_than_or_equal_to: proc { |user| user.age + 100 },
    only_integer: true

  validates_format_of :country, with: /\w+/
  validates_format_of :name, with: proc { /\w+/ }
  validates_format_of :description, without: /\d+/
end

class HashBackedAuthor < Hash
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def persisted?; false; end

  def name
    'hash backed author'
  end
end

class UserNumber1And2 < User
end
