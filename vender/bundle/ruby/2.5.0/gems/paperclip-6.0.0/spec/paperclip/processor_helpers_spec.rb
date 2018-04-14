require 'spec_helper'

describe Paperclip::ProcessorHelpers do
  describe '.load_processor' do
    context 'when the file exists in lib/paperclip' do
      it 'loads it correctly' do
        pathname = Pathname.new('my_app')
        main_path = 'main_path'
        alternate_path = 'alternate_path'

        Rails.stubs(:root).returns(pathname)
        File.expects(:expand_path).with(pathname.join('lib/paperclip', 'custom.rb')).returns(main_path)
        File.expects(:expand_path).with(pathname.join('lib/paperclip_processors', 'custom.rb')).returns(alternate_path)
        File.expects(:exist?).with(main_path).returns(true)
        File.expects(:exist?).with(alternate_path).returns(false)

        Paperclip.expects(:require).with(main_path)

        Paperclip.load_processor(:custom)
      end
    end

    context 'when the file exists in lib/paperclip_processors' do
      it 'loads it correctly' do
        pathname = Pathname.new('my_app')
        main_path = 'main_path'
        alternate_path = 'alternate_path'

        Rails.stubs(:root).returns(pathname)
        File.expects(:expand_path).with(pathname.join('lib/paperclip', 'custom.rb')).returns(main_path)
        File.expects(:expand_path).with(pathname.join('lib/paperclip_processors', 'custom.rb')).returns(alternate_path)
        File.expects(:exist?).with(main_path).returns(false)
        File.expects(:exist?).with(alternate_path).returns(true)

        Paperclip.expects(:require).with(alternate_path)

        Paperclip.load_processor(:custom)
      end
    end

    context 'when the file does not exist in lib/paperclip_processors' do
      it 'raises an error' do
        pathname = Pathname.new('my_app')
        main_path = 'main_path'
        alternate_path = 'alternate_path'

        Rails.stubs(:root).returns(pathname)
        File.stubs(:expand_path).with(pathname.join('lib/paperclip', 'custom.rb')).returns(main_path)
        File.stubs(:expand_path).with(pathname.join('lib/paperclip_processors', 'custom.rb')).returns(alternate_path)
        File.stubs(:exist?).with(main_path).returns(false)
        File.stubs(:exist?).with(alternate_path).returns(false)

        assert_raises(LoadError) { Paperclip.processor(:custom) }
      end
    end
  end
end
