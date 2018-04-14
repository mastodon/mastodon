require 'spec_helper'

describe "When an error happens" do
  it "raises a CommandLineError if the result code command isn't expected" do
    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.stubs(:execute)
    with_exitstatus_returning(1) do
      lambda { cmd.run }.should raise_error(Cocaine::CommandLineError)
    end
  end

  it "does not raise if the result code is expected, even if nonzero" do
    cmd = Cocaine::CommandLine.new("echo", "hello", expected_outcodes: [0, 1])
    cmd.stubs(:execute)
    with_exitstatus_returning(1) do
      lambda { cmd.run }.should_not raise_error
    end
  end

  it "adds command output to exception message if the result code is nonzero" do
    cmd = Cocaine::CommandLine.new("echo", "hello")
    error_output = "Error 315"
    cmd.
      stubs(:execute).
      returns(Cocaine::CommandLine::Output.new("", error_output))
    with_exitstatus_returning(1) do
      begin
        cmd.run
      rescue Cocaine::ExitStatusError => e
        e.message.should =~ /STDERR:\s+#{error_output}/
      end
    end
  end

  it 'passes the error message to the exception when command is not found' do
    cmd = Cocaine::CommandLine.new('test', '')
    cmd.stubs(:execute).raises(Errno::ENOENT.new("not found"))
    begin
      cmd.run
    rescue Cocaine::CommandNotFoundError => e
      expect(e.message).to eq 'No such file or directory - not found'
    end
  end

  it "should keep result code in #exitstatus" do
    cmd = Cocaine::CommandLine.new("convert")
    cmd.stubs(:execute).with("convert").returns(:correct_value)
    with_exitstatus_returning(1) do
      cmd.run rescue nil
    end
    cmd.exit_status.should == 1
  end

  it "does not blow up if running the command errored before execution" do
    assuming_no_processes_have_been_run
    command = Cocaine::CommandLine.new("echo", ":hello_world")
    command.stubs(:command).raises("An Error")

    lambda{ command.run }.should raise_error("An Error")
    command.exit_status.should eq 0
  end
end
