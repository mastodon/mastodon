require 'active_model/serializer/field'

module ActiveModel
  class Serializer
    # Holds all the meta-data about an attribute as it was specified in the
    # ActiveModel::Serializer class.
    #
    # @example
    #   class PostSerializer < ActiveModel::Serializer
    #     attribute :content
    #     attribute :name, key: :title
    #     attribute :email, key: :author_email, if: :user_logged_in?
    #     attribute :preview do
    #       truncate(object.content)
    #     end
    #
    #     def user_logged_in?
    #       current_user.logged_in?
    #     end
    #   end
    #
    class Attribute < Field
    end
  end
end
