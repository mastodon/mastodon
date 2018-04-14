require 'spec_helper'

describe Terrapin::CommandLine::PosixRunner do
  if Terrapin::CommandLine::PosixRunner.supported?
    it_behaves_like 'a command that does not block'

    it 'runs the command given and captures the output' do
      output = subject.call("echo hello")
      expect(output).to have_output "hello\n"
    end

    it 'runs the command given and captures the error output' do
      output = subject.call("echo hello 1>&2")
      expect(output).to have_error_output "hello\n"
    end

    it 'modifies the environment and runs the command given' do
      output = subject.call("echo $yes", {"yes" => "no"})
      expect(output).to have_output "no\n"
    end

    it 'sets the exitstatus when a command completes' do
      subject.call("ruby -e 'exit 0'")
      $?.exitstatus.should == 0
      subject.call("ruby -e 'exit 5'")
      $?.exitstatus.should == 5
    end

    it "runs the command it's given and allows access to stderr afterwards" do
      cmd = Terrapin::CommandLine.new(
        "ruby",
        "-e '$stdout.puts %{hello}; $stderr.puts %{goodbye}'",
        :swallow_stderr => false
      )
      cmd.run
      expect(cmd.command_output).to eq "hello\n"
      expect(cmd.command_error_output).to eq "goodbye\n"
    end
  end
end
