require 'spec_helper'

describe Cocaine::OSDetector do
  it "detects that the system is unix" do
    on_unix!
    Cocaine::OS.should be_unix
  end

  it "detects that the system is windows" do
    on_windows!
    Cocaine::OS.should be_windows
  end

  it "detects that the system is windows (mingw)" do
    on_mingw!
    Cocaine::OS.should be_windows
  end

  it "detects that the current Ruby is on Java" do
    on_java!
    Cocaine::OS.should be_java
  end
end
