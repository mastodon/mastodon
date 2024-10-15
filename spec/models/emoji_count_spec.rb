# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Status#increment/decrement_emoji!' do # rubocop:disable RSpec/DescribeClass
  subject { Fabricate(:status) }

  it 'increments emoji count' do
    subject.increment_emoji!('')
    subject.increment_emoji!('🎉')
    subject.increment_emoji!('😂')
    subject.increment_emoji!('https://hoge.com/aaa')
    expect(subject.emoji_count).to eq('🎉' => 1, '😂' => 1, 'https://hoge.com/aaa' => 1)

    subject.decrement_emoji!('')
    subject.increment_emoji!('🎉')
    subject.decrement_emoji!('😂')
    subject.increment_emoji!('https://hoge.com/aaa')
    expect(subject.emoji_count).to eq('🎉' => 2, 'https://hoge.com/aaa' => 2)
  end
end
