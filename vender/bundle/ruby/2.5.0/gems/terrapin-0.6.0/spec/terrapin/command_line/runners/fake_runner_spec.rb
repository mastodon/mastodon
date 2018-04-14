require 'spec_helper'

describe Terrapin::CommandLine::FakeRunner do
  it 'records commands' do
    subject.call("some command", :environment)
    subject.call("other command", :other_environment)
    subject.commands.should eq [["some command", :environment], ["other command", :other_environment]]
  end

  it 'can tell if a command was run' do
    subject.call("some command", :environment)
    subject.call("other command", :other_environment)
    subject.ran?("some command").should eq true
    subject.ran?("no command").should eq false
  end

  it 'can tell if a command was run even if shell options were set' do
    subject.call("something 2>/dev/null", :environment)
    subject.ran?("something").should eq true
  end

end
