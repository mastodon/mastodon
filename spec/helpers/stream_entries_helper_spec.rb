require 'rails_helper'

RSpec.describe StreamEntriesHelper, type: :helper do
  describe '#display_name' do
    it 'uses the display name when it exists' do
      account = Account.new(display_name: "Display", username: "Username")

      expect(helper.display_name(account)).to eq "Display"
    end

    it 'uses the username when display name is nil' do
      account = Account.new(display_name: nil, username: "Username")

      expect(helper.display_name(account)).to eq "Username"
    end
  end

  describe '#style_classes' do
    it do
      status = double(reblog?: false)
      classes = helper.style_classes(status, false, false, false)

      expect(classes).to eq 'entry'
    end

    it do
      status = double(reblog?: true)
      classes = helper.style_classes(status, false, false, false)

      expect(classes).to eq 'entry entry-reblog'
    end

    it do
      status = double(reblog?: false)
      classes = helper.style_classes(status, true, false, false)

      expect(classes).to eq 'entry entry-predecessor'
    end

    it do
      status = double(reblog?: false)
      classes = helper.style_classes(status, false, true, false)

      expect(classes).to eq 'entry entry-successor'
    end

    it do
      status = double(reblog?: false)
      classes = helper.style_classes(status, false, false, true)

      expect(classes).to eq 'entry entry-center'
    end

    it do
      status = double(reblog?: true)
      classes = helper.style_classes(status, true, true, true)

      expect(classes).to eq 'entry entry-predecessor entry-reblog entry-successor entry-center'
    end
  end

  describe '#microformats_classes' do
    it do
      status = double(reblog?: false)
      classes = helper.microformats_classes(status, false, false)

      expect(classes).to eq ''
    end

    it do
      status = double(reblog?: false)
      classes = helper.microformats_classes(status, true, false)

      expect(classes).to eq 'p-in-reply-to'
    end

    it do
      status = double(reblog?: false)
      classes = helper.microformats_classes(status, false, true)

      expect(classes).to eq 'p-comment'
    end

    it do
      status = double(reblog?: true)
      classes = helper.microformats_classes(status, true, false)

      expect(classes).to eq 'p-in-reply-to p-repost-of'
    end

    it do
      status = double(reblog?: true)
      classes = helper.microformats_classes(status, true, true)

      expect(classes).to eq 'p-in-reply-to p-repost-of p-comment'
    end
  end

  describe '#microformats_h_class' do
    it do
      status = double(reblog?: false)
      css_class = helper.microformats_h_class(status, false, false, false)

      expect(css_class).to eq 'h-entry'
    end

    it do
      status = double(reblog?: true)
      css_class = helper.microformats_h_class(status, false, false, false)

      expect(css_class).to eq 'h-cite'
    end

    it do
      status = double(reblog?: false)
      css_class = helper.microformats_h_class(status, true, false, false)

      expect(css_class).to eq 'h-cite'
    end

    it do
      status = double(reblog?: false)
      css_class = helper.microformats_h_class(status, false, true, false)

      expect(css_class).to eq 'h-cite'
    end

    it do
      status = double(reblog?: false)
      css_class = helper.microformats_h_class(status, false, false, true)

      expect(css_class).to eq ''
    end

    it do
      status = double(reblog?: true)
      css_class = helper.microformats_h_class(status, true, true, true)

      expect(css_class).to eq 'h-cite'
    end
  end
  
  describe '#rtl?' do
    it 'is false if text is empty' do
      expect(helper).not_to be_rtl ''
    end

    it 'is false if there are no right to left characters' do
      expect(helper).not_to be_rtl 'hello world'
    end

    it 'is false if right to left characters are fewer than 1/3 of total text' do
      expect(helper).not_to be_rtl 'hello ݟ world'
    end

    it 'is true if right to left characters are greater than 1/3 of total text' do
      expect(helper).to be_rtl 'aaݟ'
    end
  end
end
