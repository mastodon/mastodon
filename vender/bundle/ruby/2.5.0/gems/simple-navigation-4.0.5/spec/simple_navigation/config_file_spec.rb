require 'simple_navigation/config_file'

module SimpleNavigation
  describe ConfigFile do
    subject(:config_file) { ConfigFile.new(context) }

    let(:context) { :default }

    describe '#name' do
      context 'when the context is :default' do
        it 'returns navigation.rb' do
          expect(config_file.name).to eq 'navigation.rb'
        end
      end

      context 'when the context is different from :default' do
        let(:context) { :HelloWorld }

        it 'returns UNDERSCORED_CONTEXT_navigation.rb' do
          expect(config_file.name).to eq 'hello_world_navigation.rb'
        end
      end
    end
  end
end
