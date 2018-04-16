require 'json'
require 'action_pack'
require 'active_support/core_ext/class/attribute'
require 'active_support/log_subscriber'
require 'request_store'

module Lograge
  class RequestLogSubscriber < ActiveSupport::LogSubscriber
    def process_action(event)
      return if Lograge.ignore?(event)

      payload = event.payload
      data = extract_request(event, payload)
      data = before_format(data, payload)
      formatted_message = Lograge.formatter.call(data)
      logger.send(Lograge.log_level, formatted_message)
    end

    def redirect_to(event)
      RequestStore.store[:lograge_location] = event.payload[:location]
    end

    def unpermitted_parameters(event)
      RequestStore.store[:lograge_unpermitted_params] ||= []
      RequestStore.store[:lograge_unpermitted_params].concat(event.payload[:keys])
    end

    def logger
      Lograge.logger.presence || super
    end

    private

    def extract_request(event, payload)
      payload = event.payload
      data = initial_data(payload)
      data.merge!(extract_status(payload))
      data.merge!(extract_runtimes(event, payload))
      data.merge!(extract_location)
      data.merge!(extract_unpermitted_params)
      data.merge!(custom_options(event))
    end

    def initial_data(payload)
      {
        method: payload[:method],
        path: extract_path(payload),
        format: extract_format(payload),
        controller: payload[:controller],
        action: payload[:action]
      }
    end

    def extract_path(payload)
      path = payload[:path]
      strip_query_string(path)
    end

    def strip_query_string(path)
      index = path.index('?')
      index ? path[0, index] : path
    end

    if ::ActionPack::VERSION::MAJOR == 3 && ::ActionPack::VERSION::MINOR.zero?
      def extract_format(payload)
        payload[:formats].first
      end
    else
      def extract_format(payload)
        payload[:format]
      end
    end

    def extract_status(payload)
      if (status = payload[:status])
        { status: status.to_i }
      elsif (error = payload[:exception])
        exception, message = error
        { status: get_error_status_code(exception), error: "#{exception}: #{message}" }
      else
        { status: 0 }
      end
    end

    def get_error_status_code(exception)
      status = ActionDispatch::ExceptionWrapper.rescue_responses[exception]
      Rack::Utils.status_code(status)
    end

    def custom_options(event)
      options = Lograge.custom_options(event) || {}
      options.merge event.payload[:custom_payload] || {}
    end

    def before_format(data, payload)
      Lograge.before_format(data, payload)
    end

    def extract_runtimes(event, payload)
      data = { duration: event.duration.to_f.round(2) }
      data[:view] = payload[:view_runtime].to_f.round(2) if payload.key?(:view_runtime)
      data[:db] = payload[:db_runtime].to_f.round(2) if payload.key?(:db_runtime)
      data
    end

    def extract_location
      location = RequestStore.store[:lograge_location]
      return {} unless location

      RequestStore.store[:lograge_location] = nil
      { location: strip_query_string(location) }
    end

    def extract_unpermitted_params
      unpermitted_params = RequestStore.store[:lograge_unpermitted_params]
      return {} unless unpermitted_params

      RequestStore.store[:lograge_unpermitted_params] = nil
      { unpermitted_params: unpermitted_params }
    end
  end
end
