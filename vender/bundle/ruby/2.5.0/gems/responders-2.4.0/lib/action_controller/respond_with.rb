require 'active_support/core_ext/array/extract_options'
require 'action_controller/metal/mime_responds'

module ActionController #:nodoc:
  module RespondWith
    extend ActiveSupport::Concern

    included do
      class_attribute :responder, :mimes_for_respond_to
      self.responder = ActionController::Responder
      clear_respond_to
    end

    module ClassMethods
      # Defines mime types that are rendered by default when invoking
      # <tt>respond_with</tt>.
      #
      #   respond_to :html, :xml, :json
      #
      # Specifies that all actions in the controller respond to requests
      # for <tt>:html</tt>, <tt>:xml</tt> and <tt>:json</tt>.
      #
      # To specify on per-action basis, use <tt>:only</tt> and
      # <tt>:except</tt> with an array of actions or a single action:
      #
      #   respond_to :html
      #   respond_to :xml, :json, except: [ :edit ]
      #
      # This specifies that all actions respond to <tt>:html</tt>
      # and all actions except <tt>:edit</tt> respond to <tt>:xml</tt> and
      # <tt>:json</tt>.
      #
      #   respond_to :json, only: :create
      #
      # This specifies that the <tt>:create</tt> action and no other responds
      # to <tt>:json</tt>.
      def respond_to(*mimes)
        options = mimes.extract_options!

        only_actions   = Array(options.delete(:only)).map(&:to_s)
        except_actions = Array(options.delete(:except)).map(&:to_s)

        hash = mimes_for_respond_to.dup
        mimes.each do |mime|
          mime = mime.to_sym
          hash[mime]          = {}
          hash[mime][:only]   = only_actions   unless only_actions.empty?
          hash[mime][:except] = except_actions unless except_actions.empty?
        end
        self.mimes_for_respond_to = hash.freeze
      end

      # Clear all mime types in <tt>respond_to</tt>.
      #
      def clear_respond_to
        self.mimes_for_respond_to = Hash.new.freeze
      end
    end

    # For a given controller action, respond_with generates an appropriate
    # response based on the mime-type requested by the client.
    #
    # If the method is called with just a resource, as in this example -
    #
    #   class PeopleController < ApplicationController
    #     respond_to :html, :xml, :json
    #
    #     def index
    #       @people = Person.all
    #       respond_with @people
    #     end
    #   end
    #
    # then the mime-type of the response is typically selected based on the
    # request's Accept header and the set of available formats declared
    # by previous calls to the controller's class method +respond_to+. Alternatively
    # the mime-type can be selected by explicitly setting <tt>request.format</tt> in
    # the controller.
    #
    # If an acceptable format is not identified, the application returns a
    # '406 - not acceptable' status. Otherwise, the default response is to render
    # a template named after the current action and the selected format,
    # e.g. <tt>index.html.erb</tt>. If no template is available, the behavior
    # depends on the selected format:
    #
    # * for an html response - if the request method is +get+, an exception
    #   is raised but for other requests such as +post+ the response
    #   depends on whether the resource has any validation errors (i.e.
    #   assuming that an attempt has been made to save the resource,
    #   e.g. by a +create+ action) -
    #   1. If there are no errors, i.e. the resource
    #      was saved successfully, the response +redirect+'s to the resource
    #      i.e. its +show+ action.
    #   2. If there are validation errors, the response
    #      renders a default action, which is <tt>:new</tt> for a
    #      +post+ request or <tt>:edit</tt> for +patch+ or +put+.
    #   Thus an example like this -
    #
    #     respond_to :html, :xml
    #
    #     def create
    #       @user = User.new(params[:user])
    #       flash[:notice] = 'User was successfully created.' if @user.save
    #       respond_with(@user)
    #     end
    #
    #   is equivalent, in the absence of <tt>create.html.erb</tt>, to -
    #
    #     def create
    #       @user = User.new(params[:user])
    #       respond_to do |format|
    #         if @user.save
    #           flash[:notice] = 'User was successfully created.'
    #           format.html { redirect_to(@user) }
    #           format.xml { render xml: @user }
    #         else
    #           format.html { render action: "new" }
    #           format.xml { render xml: @user }
    #         end
    #       end
    #     end
    #
    # * for a JavaScript request - if the template isn't found, an exception is
    #   raised.
    # * for other requests - i.e. data formats such as xml, json, csv etc, if
    #   the resource passed to +respond_with+ responds to <code>to_<format></code>,
    #   the method attempts to render the resource in the requested format
    #   directly, e.g. for an xml request, the response is equivalent to calling
    #   <code>render xml: resource</code>.
    #
    # === Nested resources
    #
    # As outlined above, the +resources+ argument passed to +respond_with+
    # can play two roles. It can be used to generate the redirect url
    # for successful html requests (e.g. for +create+ actions when
    # no template exists), while for formats other than html and JavaScript
    # it is the object that gets rendered, by being converted directly to the
    # required format (again assuming no template exists).
    #
    # For redirecting successful html requests, +respond_with+ also supports
    # the use of nested resources, which are supplied in the same way as
    # in <code>form_for</code> and <code>polymorphic_url</code>. For example -
    #
    #   def create
    #     @project = Project.find(params[:project_id])
    #     @task = @project.comments.build(params[:task])
    #     flash[:notice] = 'Task was successfully created.' if @task.save
    #     respond_with(@project, @task)
    #   end
    #
    # This would cause +respond_with+ to redirect to <code>project_task_url</code>
    # instead of <code>task_url</code>. For request formats other than html or
    # JavaScript, if multiple resources are passed in this way, it is the last
    # one specified that is rendered.
    #
    # === Customizing response behavior
    #
    # Like +respond_to+, +respond_with+ may also be called with a block that
    # can be used to overwrite any of the default responses, e.g. -
    #
    #   def create
    #     @user = User.new(params[:user])
    #     flash[:notice] = "User was successfully created." if @user.save
    #
    #     respond_with(@user) do |format|
    #       format.html { render }
    #     end
    #   end
    #
    # The argument passed to the block is an ActionController::MimeResponds::Collector
    # object which stores the responses for the formats defined within the
    # block. Note that formats with responses defined explicitly in this way
    # do not have to first be declared using the class method +respond_to+.
    #
    # Also, a hash passed to +respond_with+ immediately after the specified
    # resource(s) is interpreted as a set of options relevant to all
    # formats. Any option accepted by +render+ can be used, e.g.
    #
    #   respond_with @people, status: 200
    #
    # However, note that these options are ignored after an unsuccessful attempt
    # to save a resource, e.g. when automatically rendering <tt>:new</tt>
    # after a post request.
    #
    # Three additional options are relevant specifically to +respond_with+ -
    # 1. <tt>:location</tt> - overwrites the default redirect location used after
    #    a successful html +post+ request.
    # 2. <tt>:action</tt> - overwrites the default render action used after an
    #    unsuccessful html +post+ request.
    # 3. <tt>:render</tt> - allows to pass any options directly to the <tt>:render<tt/>
    #    call after unsuccessful html +post+ request. Usefull if for example you
    #    need to render a template which is outside of controller's path or you
    #    want to override the default http <tt>:status</tt> code, e.g.
    #
    #    response_with(resource, render: { template: 'path/to/template', status: 422 })
    def respond_with(*resources, &block)
      if self.class.mimes_for_respond_to.empty?
        raise "In order to use respond_with, first you need to declare the " \
          "formats your controller responds to in the class level."
      end

      mimes = collect_mimes_from_class_level
      collector = ActionController::MimeResponds::Collector.new(mimes, request.variant)
      block.call(collector) if block_given?

      if format = collector.negotiate_format(request)
        _process_format(format)
        options = resources.size == 1 ? {} : resources.extract_options!
        options = options.clone
        options[:default_response] = collector.response
        (options.delete(:responder) || self.class.responder).call(self, resources, options)
      else
        raise ActionController::UnknownFormat
      end
    end

    protected

    # Before action callback that can be used to prevent requests that do not
    # match the mime types defined through <tt>respond_to</tt> from being executed.
    #
    #   class PeopleController < ApplicationController
    #     respond_to :html, :xml, :json
    #
    #     before_action :verify_requested_format!
    #   end
    def verify_requested_format!
      mimes = collect_mimes_from_class_level
      collector = ActionController::MimeResponds::Collector.new(mimes, request.variant)

      unless collector.negotiate_format(request)
        raise ActionController::UnknownFormat
      end
    end

    alias :verify_request_format! :verify_requested_format!

    # Collect mimes declared in the class method respond_to valid for the
    # current action.
    def collect_mimes_from_class_level #:nodoc:
      action = action_name.to_s

      self.class.mimes_for_respond_to.keys.select do |mime|
        config = self.class.mimes_for_respond_to[mime]

        if config[:except]
          !config[:except].include?(action)
        elsif config[:only]
          config[:only].include?(action)
        else
          true
        end
      end
    end
  end
end
