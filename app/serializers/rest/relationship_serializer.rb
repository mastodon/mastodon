# frozen_string_literal: true

class REST::RelationshipSerializer < ActiveModel::Serializer
  attributes :id, :following, :followed_by, :blocking,
             :muting, :requested, :domain_blocking

  def id
    object.id.to_s
  end

  def following
    instance_options[:relationships].following[object.id] || false
  end

  def followed_by
    instance_options[:relationships].followed_by[object.id] || false
  end

  def blocking
    instance_options[:relationships].blocking[object.id] || false
  end

  def muting
    instance_options[:relationships].muting[object.id] || false
  end

  def requested
    instance_options[:relationships].requested[object.id] || false
  end

  def domain_blocking
    instance_options[:relationships].domain_blocking[object.id] || false
  end
end
