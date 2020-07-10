# frozen_string_literal: true

class REST::RelationshipSerializer < ActiveModel::Serializer
  attributes :id, :following, :showing_reblogs, :followed_by, :blocking, :blocked_by,
             :muting, :muting_notifications, :requested, :domain_blocking,
             :endorsed, :note

  def id
    object.id.to_s
  end

  def following
    instance_options[:relationships].following[object.id] ? true : false
  end

  def showing_reblogs
    (instance_options[:relationships].following[object.id] || {})[:reblogs] ||
      (instance_options[:relationships].requested[object.id] || {})[:reblogs] ||
      false
  end

  def followed_by
    instance_options[:relationships].followed_by[object.id] || false
  end

  def blocking
    instance_options[:relationships].blocking[object.id] || false
  end

  def blocked_by
    instance_options[:relationships].blocked_by[object.id] || false
  end

  def muting
    instance_options[:relationships].muting[object.id] ? true : false
  end

  def muting_notifications
    (instance_options[:relationships].muting[object.id] || {})[:notifications] || false
  end

  def requested
    instance_options[:relationships].requested[object.id] ? true : false
  end

  def domain_blocking
    instance_options[:relationships].domain_blocking[object.id] || false
  end

  def endorsed
    instance_options[:relationships].endorsed[object.id] || false
  end

  def note
    (instance_options[:relationships].account_note[object.id] || {})[:comment] || ''
  end
end
