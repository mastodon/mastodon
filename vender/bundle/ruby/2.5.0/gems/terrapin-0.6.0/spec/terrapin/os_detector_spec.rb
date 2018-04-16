require 'spec_helper'

describe Terrapin::OSDetector do
  it "detects that the system is unix" do
    on_unix!
    Terrapin::OS.should be_unix
  end

  it "detects that the system is windows" do
    on_windows!
    Terrapin::OS.should be_windows
  end

  it "detects that the system is windows (mingw)" do
    on_mingw!
    Terrapin::OS.should be_windows
  end

  it "detects that the current Ruby is on Java" do
    on_java!
    Terrapin::OS.should be_java
  end
end
