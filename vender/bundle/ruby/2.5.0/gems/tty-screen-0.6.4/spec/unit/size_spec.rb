require 'delegate'

RSpec.describe TTY::Screen, '#size' do
  class Output < SimpleDelegator
    def winsize
      [100, 200]
    end

    def ioctl(control, buf)
      buf.replace("3\x00\xD3\x00\xF2\x04\xCA\x02\x00")
      0
    end
  end

  let(:output) { Output.new(StringIO.new('', 'w+')) }

  context 'size' do
    it "correctly falls through choices" do
      screen = TTY::Screen
      old_output = screen.output
      screen.output = output

      allow(screen).to receive(:size_from_java).and_return(nil)
      allow(screen).to receive(:size_from_win_api).and_return(nil)
      allow(screen).to receive(:size_from_ioctl).and_return(nil)
      allow(screen).to receive(:size_from_io_console).and_return([51, 280])
      allow(screen).to receive(:size_from_readline).and_return(nil)

      expect(screen.size).to eq([51, 280])
      expect(screen).to have_received(:size_from_java)
      expect(screen).to have_received(:size_from_win_api)
      expect(screen).to have_received(:size_from_ioctl)
      expect(screen).to_not have_received(:size_from_readline)

      screen.output = old_output
    end
  end

  context "size from java" do
    it "doesn't import java on non-jruby platform" do
      screen = TTY::Screen
      allow(screen).to receive(:jruby?).and_return(false)
      expect(screen.size_from_java).to eq(nil)
    end

    it "imports java library on jruby" do
      screen = TTY::Screen
      class << screen
        def java_import(*args); end
      end
      terminal = double(:terminal, get_height: 51, get_width: 211)
      factory = double(:factory, get: terminal)
      stub_const("TTY::Screen::TerminalFactory", factory)

      allow(screen).to receive(:jruby?).and_return(true)
      allow(screen).to receive(:require).with('java').and_return(true)
      allow(screen).to receive(:java_import)

      expect(screen.size_from_java).to eq([51, 211])
    end
  end

  context 'from io console' do
    it "doesn't calculate size if jruby " do
      screen = TTY::Screen
      allow(screen).to receive(:jruby?).and_return(true)
      expect(screen.size_from_io_console).to eq(nil)
    end

    it "calcualtes the size" do
      screen = TTY::Screen
      old_output = screen.output
      screen.output = output

      allow(screen).to receive(:jruby?).and_return(false)
      allow(screen).to receive(:require).with('io/console').
        and_return(true)
      allow(output).to receive(:tty?).and_return(true)
      allow(IO).to receive(:method_defined?).with(:winsize).and_return(true)
      allow(output).to receive(:winsize).and_return([100, 200])

      expect(screen.size_from_io_console).to eq([100, 200])
      expect(output).to have_received(:winsize)

      screen.output = old_output
    end

    it "doesn't calculate size if io/console not available" do
      screen = TTY::Screen
      allow(screen).to receive(:jruby?).and_return(false)
      allow(screen).to receive(:require).with('io/console').
        and_raise(LoadError)
      expect(screen.size_from_io_console).to eq(nil)
    end

    it "doesn't calculate size if it is run without a console" do
      screen = TTY::Screen
      allow(screen).to receive(:jruby?).and_return(false)
      allow(screen).to receive(:require).with('io/console').
        and_return(true)
      allow(screen.output).to receive(:tty?).and_return(true)
      allow(IO).to receive(:method_defined?).with(:winsize).and_return(false)
      expect(screen.size_from_io_console).to eq(nil)
    end
  end

  context "from ioctl" do
    it "reads terminal size" do
      screen = TTY::Screen
      old_output = screen.output
      screen.output = output
      allow(screen).to receive(:jruby?).and_return(false)
      expect(screen.size_from_ioctl).to eq([51, 211])
      screen.output = old_output
    end

    it "skips reading on jruby" do
      allow(TTY::Screen).to receive(:jruby?).and_return(true)
      expect(TTY::Screen.size_from_ioctl).to eq(nil)
    end
  end

  context 'from tput' do
    it "doesn't run command if outside of terminal" do
      allow(TTY::Screen.output).to receive(:tty?).and_return(false)
      expect(TTY::Screen.size_from_tput).to eq(nil)
    end

    it "runs tput commands" do
      screen = TTY::Screen
      allow(screen.output).to receive(:tty?).and_return(true)
      allow(screen).to receive(:run_command).with('tput', 'lines').and_return(51)
      allow(screen).to receive(:run_command).with('tput', 'cols').and_return(280)
      expect(screen.size_from_tput).to eq([51, 280])
    end

    it "doesn't return zero size" do
      screen = TTY::Screen
      allow(screen.output).to receive(:tty?).and_return(true)
      allow(screen).to receive(:run_command).with('tput', 'lines').and_return(0)
      allow(screen).to receive(:run_command).with('tput', 'cols').and_return(0)
      expect(screen.size_from_tput).to eq(nil)
    end
  end

  context 'size from stty' do
    it "doesn't run command if outside of terminal" do
      allow(TTY::Screen.output).to receive(:tty?).and_return(false)
      expect(TTY::Screen.size_from_stty).to eq(nil)
    end

    it "runs stty commands" do
      screen = TTY::Screen
      allow(screen.output).to receive(:tty?).and_return(true)
      allow(screen).to receive(:run_command).with('stty', 'size').and_return("51 280")
      expect(screen.size_from_stty).to eq([51, 280])
    end

    it "doesn't return zero size" do
      screen = TTY::Screen
      allow(screen.output).to receive(:tty?).and_return(true)
      allow(screen).to receive(:run_command).with('stty', 'size').and_return("0 0")
      expect(screen.size_from_stty).to eq(nil)
    end
  end

  context 'size from env' do
    it "doesn't calculate size without COLUMNS key" do
      screen = TTY::Screen
      old_env = screen.env
      screen.env = {'COLUMNS' => nil}
      expect(screen.size_from_env).to eq(nil)
      screen.env = old_env
    end

    it "extracts lines and columns from environment" do
      screen = TTY::Screen
      old_env = screen.env
      screen.env = {'COLUMNS' => '280', 'LINES' => '51'}
      expect(screen.size_from_env).to eq([51, 280])
      screen.env = old_env
    end

    it "doesn't return zero size" do
      screen = TTY::Screen
      old_env = screen.env
      screen.env = {'COLUMNS' => '0', 'LINES' => '0'}
      expect(screen.size_from_env).to eq(nil)
      screen.env = old_env
    end
  end

  context 'from ansicon' do
    it "doesn't calculate size without ANSICON key" do
      screen = TTY::Screen
      old_env = screen.env
      screen.env = {'ANSICON' => nil}
      expect(screen.size_from_ansicon).to eq(nil)
      screen.env = old_env
    end

    it "extracts lines and columns from environment" do
      screen = TTY::Screen
      old_env = screen.env
      screen.env = {'ANSICON' => '(280x51)'}
      expect(screen.size_from_ansicon).to eq([51, 280])
      screen.env = old_env
    end

    it "doesn't return zero size" do
      screen = TTY::Screen
      old_env = screen.env
      screen.env = {'ANSICON' => '(0x0)'}
      expect(screen.size_from_ansicon).to eq(nil)
      screen.env = old_env
    end
  end

  context 'default size' do
    it "suggests default terminal size" do
      expect(TTY::Screen::DEFAULT_SIZE).to eq([27, 80])
    end
  end
end
