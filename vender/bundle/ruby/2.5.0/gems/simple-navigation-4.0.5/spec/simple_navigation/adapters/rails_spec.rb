module SimpleNavigation
  module Adapters
    describe Rails do
      let(:action_controller) { ActionController::Base }
      let(:adapter) { Rails.new(context) }
      let(:context) { double(:context, controller: controller) }
      let(:controller) { double(:controller) }
      let(:request) { double(:request) }
      let(:simple_navigation) { SimpleNavigation }
      let(:template) { double(:template, request: request) }

      describe '.register' do
        before { allow(action_controller).to receive(:include) }

        it 'calls set_env' do
          app_path = RailsApp::Application.root
          expect(simple_navigation).to receive(:set_env).with(app_path, 'test')
          simple_navigation.register
        end

        it 'extends the ActionController::Base with the Helpers' do
          expect(action_controller).to receive(:include)
                                       .with(SimpleNavigation::Helpers)
          simple_navigation.register
        end

        shared_examples 'installing helper method' do |method|
          it "installs the #{method} method as helper method" do
            simple_navigation.register

            helper_methods = action_controller.send(:_helper_methods)
            expect(helper_methods).to include(method)
          end
        end

        it_behaves_like 'installing helper method', :render_navigation
        it_behaves_like 'installing helper method', :active_navigation_item_name
        it_behaves_like 'installing helper method', :active_navigation_item_key
        it_behaves_like 'installing helper method', :active_navigation_item
        it_behaves_like 'installing helper method', :active_navigation_item_container
      end

      describe '#initialize' do
        context "when the controller's template is set" do
          before { allow(controller).to receive_messages(instance_variable_get: template) }

          it "sets the adapter's request accordingly" do
            expect(adapter.request).to be request
          end
        end

        context "when the controller's template is not set" do
          before { allow(controller).to receive_messages(instance_variable_get: nil) }

          it "sets the adapter's request to nil" do
            expect(adapter.request).to be_nil
          end
        end

        it "sets the adapter's controller to the context's controller" do
          expect(adapter.controller).to be controller
        end

        context "when the controller's template is stored as instance var (Rails2)" do
          context "when the controller's template is set" do
            before { allow(controller).to receive_messages(instance_variable_get: template) }

            it "sets the adapter's template accordingly" do
              expect(adapter.template).to be template
            end
          end

          context "when the controller's template is not set" do
            before { allow(controller).to receive_messages(instance_variable_get: nil) }

            it "set the adapter's template to nil" do
              expect(adapter.template).to be_nil
            end
          end
        end

        context "when the controller's template is stored as view_context (Rails3)" do
          context 'and the template is set' do
            before { allow(controller).to receive_messages(view_context: template) }

            it "sets the adapter's template accordingly" do
              expect(adapter.template).to be template
            end
          end

          context 'and the template is not set' do
            before { allow(controller).to receive_messages(view_context: nil) }

            it "sets the adapter's template to nil" do
              expect(adapter.template).to be_nil
            end
          end
        end
      end

      describe '#request_uri' do
        context "when the adapter's request is set" do
          before { allow(adapter).to receive_messages(request: request) }

          context 'and request.fullpath is defined' do
            let(:request) { double(:request, fullpath: '/fullpath') }

            it "sets the adapter's request_uri to the request.fullpath" do
              expect(adapter.request_uri).to eq '/fullpath'
            end
          end

          context 'and request.fullpath is not defined' do
            let(:request) { double(:request, request_uri: '/request_uri') }

            before { allow(adapter).to receive_messages(request: request) }

            it "sets the adapter's request_uri to the request.request_uri" do
              expect(adapter.request_uri).to eq '/request_uri'
            end
          end
        end

        context "when the adapter's request is not set" do
          before { allow(adapter).to receive_messages(request: nil) }

          it "sets the adapter's request_uri to an empty string" do
            expect(adapter.request_uri).to eq ''
          end
        end
      end

      describe '#request_path' do
        context "when the adapter's request is set" do
          let(:request) { double(:request, path: '/request_path') }

          before { allow(adapter).to receive_messages(request: request) }

          it "sets the adapter's request_path to the request.path" do
            expect(adapter.request_path).to eq '/request_path'
          end
        end

        context "when the adapter's request is not set" do
          before { allow(adapter).to receive_messages(request: nil) }

          it "sets the adapter's request_path to an empty string" do
            expect(adapter.request_path).to eq ''
          end
        end
      end

      describe '#context_for_eval' do
        context "when the adapter's controller is set" do
          before { adapter.instance_variable_set(:@controller, controller) }

          context "and the adapter's template is set" do
            before { adapter.instance_variable_set(:@template, template) }

            it "sets the adapter's context_for_eval to the template" do
              expect(adapter.context_for_eval).to be template
            end
          end

          context "and the adapter's template is not set" do
            before { adapter.instance_variable_set(:@template, nil) }

            it "sets the adapter's context_for_eval to the controller" do
              expect(adapter.context_for_eval).to be controller
            end
          end
        end

        context "when the adapter's controller is not set" do
          before { adapter.instance_variable_set(:@controller, nil) }

          context "and the adapter's template is set" do
            before { adapter.instance_variable_set(:@template, template) }

            it "sets the adapter's context_for_eval to the template" do
              expect(adapter.context_for_eval).to be template
            end
          end

          context "and the adapter's template is not set" do
            before { adapter.instance_variable_set(:@template, nil) }

            it 'raises an exception' do
              expect{ adapter.context_for_eval }.to raise_error
            end
          end
        end
      end

      describe '#current_page?' do
        context "when the adapter's template is set" do
          before { allow(adapter).to receive_messages(template: template) }

          it 'delegates the call to the template' do
            expect(template).to receive(:current_page?).with(:page)
            adapter.current_page?(:page)
          end
        end

        context "when the adapter's template is not set" do
          before { allow(adapter).to receive_messages(template: nil) }

          it 'returns false' do
            expect(adapter.current_page?(:page)).to be_falsey
          end
        end

        context 'when the given url is nil' do
          it 'returns false' do
            expect(adapter.current_page?(nil)).to be_falsey
          end
        end
      end

      describe '#link_to' do
        let(:options) { double(:options) }

        context "when the adapter's template is set" do
          before { allow(adapter).to receive_messages(template: template, html_safe: 'safe_text') }

          context 'with considering item names as safe' do
            before { SimpleNavigation.config.consider_item_names_as_safe = true }
            after { SimpleNavigation.config.consider_item_names_as_safe = false }

            it 'delegates the call to the template (with html_safe text)' do
              expect(template).to receive(:link_to)
                                  .with('safe_text', 'url', options)
              adapter.link_to('text', 'url', options)
            end
          end

          context 'with considering item names as UNsafe (default)' do

            it 'delegates the call to the template (with html_safe text)' do
              expect(template).to receive(:link_to)
                                  .with('text', 'url', options)
              adapter.link_to('text', 'url', options)
            end
          end

        end

        context "when the adapter's template is not set" do
          before { allow(adapter).to receive_messages(template: nil) }

          it 'returns nil' do
            expect(adapter.link_to('text', 'url', options)).to be_nil
          end
        end
      end

      describe '#content_tag' do
        let(:options) { double(:options) }

        context "when the adapter's template is set" do
          before { allow(adapter).to receive_messages(template: template, html_safe: 'safe_text') }

          it 'delegates the call to the template (with html_safe text)' do
            expect(template).to receive(:content_tag)
                                .with(:div, 'safe_text', options)
            adapter.content_tag(:div, 'text', options)
          end
        end

        context "when the adapter's template is not set" do
          before { allow(adapter).to receive_messages(template: nil) }

          it 'returns nil' do
            expect(adapter.content_tag(:div, 'text', options)).to be_nil
          end
        end
      end

    end
  end
end
