require 'fileutils'
require 'simple_navigation/config_file_finder'

module SimpleNavigation
  describe ConfigFileFinder do
    subject(:finder) { ConfigFileFinder.new(paths) }

    let(:paths) { ['/path/one', '/path/two'] }

    describe '#find', memfs: true do
      before { FileUtils.mkdir_p(paths) }

      context 'when the context is :default' do
        let(:context) { :default }

        context 'and a navigation.rb file is found in one of the paths' do
          before { FileUtils.touch('/path/one/navigation.rb') }

          it 'returns its full path' do
            expect(finder.find(context)).to eq '/path/one/navigation.rb'
          end
        end

        context 'and no navigation.rb file is found in the paths' do
          it 'raises an exception' do
            expect{ finder.find(context) }.to raise_error
          end
        end
      end

      context 'when the context is :other' do
        let(:context) { :other }

        context 'and a other_navigation.rb file is found in one of the paths' do
          before { FileUtils.touch('/path/two/other_navigation.rb') }

          it 'returns its full path' do
            expect(finder.find(context)).to eq '/path/two/other_navigation.rb'
          end
        end

        context 'and no other_navigation.rb file is found in the paths' do
          it 'raise an exception' do
            expect{ finder.find(context) }.to raise_error
          end
        end
      end
    end
  end
end
