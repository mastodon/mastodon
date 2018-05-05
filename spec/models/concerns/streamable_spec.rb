# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Streamable do
  class Parent
    def title; end

    def target; end

    def thread; end

    def self.has_one(*); end

    def self.after_create; end
  end

  class Child < Parent
    include Streamable
  end

  child = Child.new

  describe '#title' do
    it 'calls Parent#title' do
      expect_any_instance_of(Parent).to receive(:title)
      child.title
    end
  end

  describe '#content' do
    it 'calls #title' do
      expect_any_instance_of(Parent).to receive(:title)
      child.content
    end
  end

  describe '#target' do
    it 'calls Parent#target' do
      expect_any_instance_of(Parent).to receive(:target)
      child.target
    end
  end

  describe '#object_type' do
    it 'returns :activity' do
      expect(child.object_type).to eq :activity
    end
  end

  describe '#thread' do
    it 'calls Parent#thread' do
      expect_any_instance_of(Parent).to receive(:thread)
      child.thread
    end
  end

  describe '#hidden?' do
    it 'returns false' do
      expect(child.hidden?).to be false
    end
  end
end
