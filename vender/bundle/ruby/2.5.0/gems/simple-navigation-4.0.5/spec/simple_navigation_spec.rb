describe SimpleNavigation do
  before { subject.config_file_path = 'path_to_config' }

  describe 'config_file_path=' do
    before { subject.config_file_paths = ['existing_path'] }

    it 'overrides the config_file_paths' do
      subject.config_file_path = 'new_path'
      expect(subject.config_file_paths).to eq ['new_path']
    end
  end

  describe '.default_config_file_path' do
    before { allow(subject).to receive_messages(root: 'root') }

    it 'returns the config file path according to :root setting' do
      expect(subject.default_config_file_path).to eq 'root/config'
    end
  end

  describe 'Regarding renderers' do
    it 'registers the builtin renderers by default' do
      expect(subject.registered_renderers).not_to be_empty
    end

    describe '.register_renderer' do
      let(:renderer) { double(:renderer) }

      it 'adds the specified renderer to the list of renderers' do
        subject.register_renderer(my_renderer: renderer)
        expect(subject.registered_renderers[:my_renderer]).to be renderer
      end
    end
  end

  describe '.set_env' do
    before do
      subject.config_file_paths = []
      allow(subject).to receive_messages(default_config_file_path: 'default_path')
      subject.set_env('root', 'my_env')
    end

    it 'sets the root' do
      expect(subject.root).to eq 'root'
    end

    it 'sets the environment' do
      expect(subject.environment).to eq 'my_env'
    end

    it 'adds the default-config path to the list of config_file_paths' do
      expect(subject.config_file_paths).to eq ['default_path']
    end
  end

  describe '.load_config', memfs: true do
    let(:paths) { ['/path/one', '/path/two'] }

    before do
      FileUtils.mkdir_p(paths)
      allow(subject).to receive_messages(config_file_paths: paths)
    end

    context 'when the config file for the context exists' do
      before do
        File.open('/path/two/navigation.rb', 'w') { |f| f.puts 'default content' }
        File.open('/path/one/other_navigation.rb', 'w') { |f| f.puts 'other content' }
      end

      context 'when no context is provided' do
        it 'stores the configuration in config_files for the default context' do
          subject.load_config
          expect(subject.config_files[:default]).to eq "default content\n"
        end
      end

      context 'when a context is provided' do
        it 'stores the configuration in config_files for the given context' do
          subject.load_config(:other)
          expect(subject.config_files[:other]).to eq "other content\n"
        end
      end

      context 'and environment is production' do
        before { allow(subject).to receive_messages(environment: 'production') }

        it 'loads the config file only for the first call' do
          subject.load_config
          File.open('/path/two/navigation.rb', 'w') { |f| f.puts 'new content' }
          subject.load_config
          expect(subject.config_files[:default]).to eq "default content\n"
        end
      end

      context "and environment isn't production" do
        it 'loads the config file for every call' do
          subject.load_config
          File.open('/path/two/navigation.rb', 'w') { |f| f.puts 'new content' }
          subject.load_config
          expect(subject.config_files[:default]).to eq "new content\n"
        end
      end
    end

    context "when the config file for the context doesn't exists" do
      it 'raises an exception' do
        expect{ subject.load_config }.to raise_error
      end
    end
  end

  describe '.config' do
    it 'returns the Configuration singleton instance' do
      expect(subject.config).to be SimpleNavigation::Configuration.instance
    end
  end

  describe '.active_item_container_for' do
    let(:primary) { double(:primary) }

    before { allow(subject.config).to receive_messages(primary_navigation: primary) }

    context 'when level is :all' do
      it 'returns the primary_navigation' do
        nav = subject.active_item_container_for(:all)
        expect(nav).to be primary
      end
    end

    context 'when level is :leaves' do
      it 'returns the currently active leaf-container' do
        expect(primary).to receive(:active_leaf_container)
        subject.active_item_container_for(:leaves)
      end
    end

    context 'when level is a Range' do
      it 'takes the min of the range to lookup the active container' do
        expect(primary).to receive(:active_item_container_for).with(2)
        subject.active_item_container_for(2..3)
      end
    end

    context 'when level is an Integer' do
      it 'considers the Integer to lookup the active container' do
        expect(primary).to receive(:active_item_container_for).with(1)
        subject.active_item_container_for(1)
      end
    end

    context 'when level is something else' do
      it 'raises an exception' do
        expect{
          subject.active_item_container_for('something else')
        }.to raise_error
      end
    end
  end

  describe '.load_adapter' do
    shared_examples 'loading the right adapter' do |framework, adapter|
      context "when the context is #{framework}" do
        before do
          allow(subject).to receive_messages(framework: framework)
          subject.load_adapter
        end

        it "returns the #{framework} adapter" do
          adapter_class = SimpleNavigation::Adapters.const_get(adapter)
          expect(subject.adapter_class).to be adapter_class
        end
      end
    end

    it_behaves_like 'loading the right adapter', :rails,   :Rails
    it_behaves_like 'loading the right adapter', :padrino, :Padrino
    it_behaves_like 'loading the right adapter', :sinatra, :Sinatra
  end

  describe '.init_adapter_from' do
    let(:adapter) { double(:adapter) }
    let(:adapter_class) { double(:adapter_class, new: adapter) }

    it 'sets the adapter to a new instance of adapter_class' do
      subject.adapter_class = adapter_class
      subject.init_adapter_from(:default)
      expect(subject.adapter).to be adapter
    end
  end
end
