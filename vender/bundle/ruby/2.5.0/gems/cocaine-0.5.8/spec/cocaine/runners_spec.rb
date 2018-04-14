require 'spec_helper'

describe "When picking a Runner" do
  it "uses the BackticksRunner by default" do
    Cocaine::CommandLine::ProcessRunner.stubs(:supported?).returns(false)
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(false)

    cmd = Cocaine::CommandLine.new("echo", "hello")

    cmd.runner.class.should == Cocaine::CommandLine::BackticksRunner
  end

  it "uses the ProcessRunner on 1.9 and it's available" do
    Cocaine::CommandLine::ProcessRunner.stubs(:supported?).returns(true)
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(false)

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should == Cocaine::CommandLine::ProcessRunner
  end

  it "uses the PosixRunner if the PosixRunner is available" do
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(true)

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should == Cocaine::CommandLine::PosixRunner
  end

  it "uses the BackticksRunner if the PosixRunner is available, but we told it to use Backticks all the time" do
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(true)
    Cocaine::CommandLine.runner = Cocaine::CommandLine::BackticksRunner.new

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should == Cocaine::CommandLine::BackticksRunner
  end

  it "uses the BackticksRunner if the PosixRunner is available, but we told it to use Backticks" do
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(true)

    cmd = Cocaine::CommandLine.new("echo", "hello", :runner => Cocaine::CommandLine::BackticksRunner.new)
    cmd.runner.class.should == Cocaine::CommandLine::BackticksRunner
  end

  it "can go into 'Fake' mode" do
    Cocaine::CommandLine.fake!

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should eq Cocaine::CommandLine::FakeRunner
  end

  it "can turn off Fake mode" do
    Cocaine::CommandLine.fake!
    Cocaine::CommandLine.unfake!

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should_not eq Cocaine::CommandLine::FakeRunner
  end

  it "can use a FakeRunner even if not in Fake mode" do
    Cocaine::CommandLine.unfake!

    cmd = Cocaine::CommandLine.new("echo", "hello", :runner => Cocaine::CommandLine::FakeRunner.new)
    cmd.runner.class.should eq Cocaine::CommandLine::FakeRunner
  end
end

describe 'When running an executable in the supplemental path' do
  before do
    path = Pathname.new(File.dirname(__FILE__)) + '..' + 'support'
    File.open(path + 'ls', 'w'){|f| f.puts "#!/bin/sh\necho overridden-ls\n" }
    FileUtils.chmod(0755, path + 'ls')
    Cocaine::CommandLine.path = path
  end

  after do
    FileUtils.rm_f("#{Cocaine::CommandLine.path}/ls")
  end

  [
    Cocaine::CommandLine::BackticksRunner,
    Cocaine::CommandLine::PopenRunner,
    Cocaine::CommandLine::PosixRunner,
    Cocaine::CommandLine::ProcessRunner
  ].each do |runner_class|
    if runner_class.supported?
      describe runner_class do
        describe '#run' do
          it 'finds the correct executable' do
            Cocaine::CommandLine.runner = runner_class.new
            command = Cocaine::CommandLine.new('ls')
            result = command.run
            expect(result.strip).to eq('overridden-ls')
          end
        end
      end
    end
  end
end
