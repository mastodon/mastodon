require 'helper'
require 'rack/events'

module Rack
  class TestEvents < Rack::TestCase
    class EventMiddleware
      attr_reader :events

      def initialize events
        @events = events
      end

      def on_start req, res
        events << [self, __method__]
      end

      def on_commit req, res
        events << [self, __method__]
      end

      def on_send req, res
        events << [self, __method__]
      end

      def on_finish req, res
        events << [self, __method__]
      end

      def on_error req, res, e
        events << [self, __method__]
      end
    end

    def test_events_fire
      events = []
      ret = [200, {}, []]
      app = lambda { |env| events << [app, :call]; ret }
      se = EventMiddleware.new events
      e = Events.new app, [se]
      triple = e.call({})
      response_body = []
      triple[2].each { |x| response_body << x }
      triple[2].close
      triple[2] = response_body
      assert_equal ret, triple
      assert_equal [[se, :on_start],
                    [app, :call],
                    [se, :on_commit],
                    [se, :on_send],
                    [se, :on_finish],
      ], events
    end

    def test_send_and_finish_are_not_run_until_body_is_sent
      events = []
      ret = [200, {}, []]
      app = lambda { |env| events << [app, :call]; ret }
      se = EventMiddleware.new events
      e = Events.new app, [se]
      triple = e.call({})
      assert_equal [[se, :on_start],
                    [app, :call],
                    [se, :on_commit],
      ], events
    end

    def test_send_is_called_on_each
      events = []
      ret = [200, {}, []]
      app = lambda { |env| events << [app, :call]; ret }
      se = EventMiddleware.new events
      e = Events.new app, [se]
      triple = e.call({})
      triple[2].each { |x| }
      assert_equal [[se, :on_start],
                    [app, :call],
                    [se, :on_commit],
                    [se, :on_send],
      ], events
    end

    def test_finish_is_called_on_close
      events = []
      ret = [200, {}, []]
      app = lambda { |env| events << [app, :call]; ret }
      se = EventMiddleware.new events
      e = Events.new app, [se]
      triple = e.call({})
      triple[2].each { |x| }
      triple[2].close
      assert_equal [[se, :on_start],
                    [app, :call],
                    [se, :on_commit],
                    [se, :on_send],
                    [se, :on_finish],
      ], events
    end

    def test_finish_is_called_in_reverse_order
      events = []
      ret = [200, {}, []]
      app = lambda { |env| events << [app, :call]; ret }
      se1 = EventMiddleware.new events
      se2 = EventMiddleware.new events
      se3 = EventMiddleware.new events

      e = Events.new app, [se1, se2, se3]
      triple = e.call({})
      triple[2].each { |x| }
      triple[2].close

      groups = events.group_by { |x| x.last }
      assert_equal groups[:on_start].map(&:first), groups[:on_finish].map(&:first).reverse
      assert_equal groups[:on_commit].map(&:first), groups[:on_finish].map(&:first)
      assert_equal groups[:on_send].map(&:first), groups[:on_finish].map(&:first)
    end

    def test_finish_is_called_if_there_is_an_exception
      events = []
      ret = [200, {}, []]
      app = lambda { |env| raise }
      se = EventMiddleware.new events
      e = Events.new app, [se]
      assert_raises(RuntimeError) do
        e.call({})
      end
      assert_equal [[se, :on_start],
                    [se, :on_error],
                    [se, :on_finish],
      ], events
    end
  end
end
