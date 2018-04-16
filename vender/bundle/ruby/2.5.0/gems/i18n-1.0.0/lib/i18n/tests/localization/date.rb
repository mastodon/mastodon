# encoding: utf-8

module I18n
  module Tests
    module Localization
      module Date
        def setup
          super
          setup_date_translations
          @date = ::Date.new(2008, 3, 1)
        end

        test "localize Date: given the short format it uses it" do
          # TODO should be Mrz, shouldn't it?
          assert_equal '01. Mar', I18n.l(@date, :format => :short, :locale => :de)
        end

        test "localize Date: given the long format it uses it" do
          assert_equal '01. März 2008', I18n.l(@date, :format => :long, :locale => :de)
        end

        test "localize Date: given the default format it uses it" do
          assert_equal '01.03.2008', I18n.l(@date, :format => :default, :locale => :de)
        end

        test "localize Date: given a day name format it returns the correct day name" do
          assert_equal 'Samstag', I18n.l(@date, :format => '%A', :locale => :de)
        end

        test "localize Date: given an abbreviated day name format it returns the correct abbreviated day name" do
          assert_equal 'Sa', I18n.l(@date, :format => '%a', :locale => :de)
        end

        test "localize Date: given a month name format it returns the correct month name" do
          assert_equal 'März', I18n.l(@date, :format => '%B', :locale => :de)
        end

        test "localize Date: given an abbreviated month name format it returns the correct abbreviated month name" do
          # TODO should be Mrz, shouldn't it?
          assert_equal 'Mar', I18n.l(@date, :format => '%b', :locale => :de)
        end

        test "localize Date: given an unknown format it does not fail" do
          assert_nothing_raised { I18n.l(@date, :format => '%x') }
        end

        test "localize Date: does not modify the options hash" do
          options = { :format => '%b', :locale => :de }
          assert_equal 'Mar', I18n.l(@date, options)
          assert_equal({ :format => '%b', :locale => :de }, options)
          assert_nothing_raised { I18n.l(@date, options.freeze) }
        end

        test "localize Date: given nil with default value it returns default" do
          assert_equal 'default', I18n.l(nil, :default => 'default')
        end

        test "localize Date: given nil it raises I18n::ArgumentError" do
          assert_raise(I18n::ArgumentError) { I18n.l(nil) }
        end

        test "localize Date: given a plain Object it raises I18n::ArgumentError" do
          assert_raise(I18n::ArgumentError) { I18n.l(Object.new) }
        end

        test "localize Date: given a format is missing it raises I18n::MissingTranslationData" do
          assert_raise(I18n::MissingTranslationData) { I18n.l(@date, :format => :missing) }
        end

        test "localize Date: it does not alter the format string" do
          assert_equal '01. Februar 2009', I18n.l(::Date.parse('2009-02-01'), :format => :long, :locale => :de)
          assert_equal '01. Oktober 2009', I18n.l(::Date.parse('2009-10-01'), :format => :long, :locale => :de)
        end

        protected

          def setup_date_translations
            I18n.backend.store_translations :de, {
              :date => {
                :formats => {
                  :default => "%d.%m.%Y",
                  :short => "%d. %b",
                  :long => "%d. %B %Y",
                },
                :day_names => %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag),
                :abbr_day_names => %w(So Mo Di Mi Do Fr  Sa),
                :month_names => %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember).unshift(nil),
                :abbr_month_names => %w(Jan Feb Mar Apr Mai Jun Jul Aug Sep Okt Nov Dez).unshift(nil)
              }
            }
          end
      end
    end
  end
end
