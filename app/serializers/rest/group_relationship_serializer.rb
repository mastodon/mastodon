# frozen_string_literal: true

class REST::GroupRelationshipSerializer < ActiveModel::Serializer
  attributes :id, :member, :requested, :role

  def id
    object.id.to_s
  end

  def member
    instance_options[:relationships].member[object.id] ? true : false
  end

  def requested
    instance_options[:relationships].requested[object.id] ? true : false
  end

  def role
    instance_options[:relationships].member[object.id] ? instance_options[:relationships].member[object.id][:role] : nil
  end
end
