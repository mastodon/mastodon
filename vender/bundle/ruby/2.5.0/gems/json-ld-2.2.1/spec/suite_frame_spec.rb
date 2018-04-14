# coding: utf-8
require_relative 'spec_helper'

describe JSON::LD do
  describe "test suite" do
    require_relative 'suite_helper'
    m = Fixtures::SuiteTest::Manifest.open("#{Fixtures::SuiteTest::SUITE}tests/frame-manifest.jsonld")
    describe m.name do
      m.entries.each do |t|
        specify "#{t.property('input')}: #{t.name}#{' (negative test)' unless t.positiveTest?}" do
          t.run self
        end
      end
    end
  end
end unless ENV['CI']