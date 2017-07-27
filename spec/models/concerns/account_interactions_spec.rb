require 'rails_helper'

describe AccountInteractions do
	describe 'muting an account' do
		before do
			@me = Fabricate(:account, username: 'Me')
			@you = Fabricate(:account, username: 'You')
		end

		context 'with the notifications option unspecified' do
			before do
				@me.mute!(@you)
			end

			it 'defaults to muting notifications' do
				expect(@me.muting_notifications?(@you)).to be(true)
			end
		end

		context 'with the notifications option set to false' do
			before do
				@me.mute!(@you, notifications: false)
			end

			it 'does not mute notifications' do
				expect(@me.muting_notifications?(@you)).to be(false)
			end
		end

		context 'with the notifications option set to true' do
			before do
				@me.mute!(@you, notifications: true)
			end

			it 'does mute notifications' do
				expect(@me.muting_notifications?(@you)).to be(true)
			end
		end
	end
end