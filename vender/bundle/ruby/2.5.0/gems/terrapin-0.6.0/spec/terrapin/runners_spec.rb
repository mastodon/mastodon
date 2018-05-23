require 'spec_helper'

describe "When picking a Runner" do
  it "uses the BackticksRunner by default" do
    Terrapin::CommandLine::ProcessRunner.stubs(:supported?).returns(false)
    Terrapin::CommandLine::PosixRunner.stubs(:supported?).returns(false)

    cmd = Terrapin::CommandLine.new("echo", "hello")

    cmd.runner.class.should == Terrapin::CommandLine::BackticksRunner
  end

  it "uses the ProcessRunner on 1.9 and it's available" do
    Terrapin::CommandLine::ProcessRunner.stubs(:supported?).returns(true)
    Terrapin::CommandLine::PosixRunner.stubs(:supported?).returns(false)

    cmd = Terrapin::CommandLine.new("echo", "hello")
    cmd.runner.class.should == Terrapin::CommandLine::ProcessRunner
  end

  it "uses the PosixRunner if the PosixRunner is available" do
    Terrapin::CommandLine::PosixRunner.stubs(:supported?).returns(true)

    cmd = Terrapin::CommandLine.new("echo", "hello")
    cmd.runner.class.should == Terrapin::CommandLine::PosixRunner
  end

  it "uses the BackticksRunner if the PosixRunner is available, but we told it to use Backticks all the time" do
    Terrapin::CommandLine::PosixRunner.stubs(:supported?).returns(true)
    Terrapin::CommandLine.runner = Terrapin::CommandLine::BackticksRunner.new

    cmd = Terrapin::CommandLine.new("echo", "hello")
    cmd.runner.class.should == Terrapin::CommandLine::BackticksRunner
  end

  it "uses the BackticksRunner if the PosixRunner is available, but we told it to use Backticks" do
    Terrapin::CommandLine::PosixRunner.stubs(:supported?).returns(true)

    cmd = Terrapin::CommandLine.new("echo", "hello", :runner => Terrapin::CommandLine::BackticksRunner.new)
    cmd.runner.class.should == Terrapin::CommandLine::BackticksRunner
  end

  it "can go into 'Fake' mode" do
    Terrapin::CommandLine.fake!

    cmd = Terrapin::CommandLine.new("echo", "hello")
    cmd.runner.class.should eq Terrapin::CommandLine::FakeRunner
  end

  it "can turn off Fake mode" do
    Terrapin::CommandLine.fake!
    Terrapin::CommandLine.unfake!

    cmd = Terrapin::CommandLine.new("echo", "hello")
    cmd.runner.class.should_not eq Terrapin::CommandLine::FakeRunner
  end

  it "can use a FakeRunner even if not in Fake mode" do
    Terrapin::CommandLine.unfake!

    cmd = Terrapin::CommandLine.new("echo", "hello", :runner => Terrapin::CommandLine::FakeRunner.new)
    cmd.runner.class.should eq Terrapin::CommandLine::FakeRunner
  end
end

describe 'When running an executable in the supplemental path' do
  before do
    path = Pathname.new(File.dirname(__FILE__)) + '..' + 'support'
    File.open(path + 'ls', 'w'){|f| f.puts "#!/bin/sh\necho overridden-ls\n" }
    FileUtils.chmod(0755, path + 'ls')
    Terrapin::CommandLine.path = path
  end

  after do
    FileUtils.rm_f("#{Terrapin::CommandLine.path}/ls")
  end

  [
    Terrapin::CommandLine::BackticksRunner,
    Terrapin::CommandLine::PopenRunner,
    Terrapin::CommandLine::PosixRunner,
    Terrapin::CommandLine::ProcessRunner
  ].each do |runner_class|
    if runner_class.supported?
      describe runner_class do
        describe '#run' do
          it 'finds the correct executable' do
            Terrapin::CommandLine.runner = runner_class.new
            command = Terrapin::CommandLine.new('ls')
            result = command.run
            expect(result.strip).to eq('overridden-ls')
          end
        end
      end
    end
  end
end
