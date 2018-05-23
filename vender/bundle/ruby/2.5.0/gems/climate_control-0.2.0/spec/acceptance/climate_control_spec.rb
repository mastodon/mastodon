require "spec_helper"

describe "Climate control" do
  it "allows modification of the environment" do
    block_run = false
    ClimateControl.modify FOO: "bar" do
      expect(ENV["FOO"]).to eq "bar"
      block_run = true
    end

    expect(ENV["FOO"]).to be_nil
    expect(block_run).to be true
  end

  it "modifies the environment" do
    with_modified_env VARIABLE_1: "bar", VARIABLE_2: "qux" do
      expect(ENV["VARIABLE_1"]).to eq "bar"
      expect(ENV["VARIABLE_2"]).to eq "qux"
    end

    expect(ENV["VARIABLE_1"]).to be_nil
    expect(ENV["VARIABLE_2"]).to be_nil
  end

  it "allows for environment variables to be assigned within the block" do
    with_modified_env VARIABLE_1: "modified" do
      ENV["ASSIGNED_IN_BLOCK"] = "assigned"
    end

    expect(ENV["ASSIGNED_IN_BLOCK"]).to eq "assigned"
  end

  it "reassigns previously set environment variables" do
    ENV["VARIABLE_ASSIGNED_BEFORE_MODIFYING_ENV"] = "original"
    expect(ENV["VARIABLE_ASSIGNED_BEFORE_MODIFYING_ENV"]).to eq "original"

    with_modified_env VARIABLE_ASSIGNED_BEFORE_MODIFYING_ENV: "overridden" do
      expect(ENV["VARIABLE_ASSIGNED_BEFORE_MODIFYING_ENV"]).to eq "overridden"
    end

    expect(ENV["VARIABLE_ASSIGNED_BEFORE_MODIFYING_ENV"]).to eq "original"
  end

  it "persists the change when overriding the variable in the block" do
    with_modified_env VARIABLE_MODIFIED_AND_THEN_ASSIGNED: "modified" do
      ENV["VARIABLE_MODIFIED_AND_THEN_ASSIGNED"] = "assigned value"
    end

    expect(ENV["VARIABLE_MODIFIED_AND_THEN_ASSIGNED"]).to eq "assigned value"
  end

  it "resets environment variables even if the block raises" do
    expect {
      with_modified_env FOO: "bar" do
        raise "broken"
      end
    }.to raise_error("broken")

    expect(ENV["FOO"]).to be_nil
  end

  it "preserves environment variables set within the block" do
    ENV["CHANGED"] = "old value"

    with_modified_env IRRELEVANT: "ignored value" do
      ENV["CHANGED"] = "new value"
    end

    expect(ENV["CHANGED"]).to eq "new value"
  end

  it "returns the value of the block" do
    value = with_modified_env VARIABLE_1: "bar" do
      "value inside block"
    end

    expect(value).to eq "value inside block"
  end

  it "handles threads correctly" do
    # failure path without mutex
    # [thread_removing_env] BAZ is assigned
    # 0.25s passes
    # [other_thread] FOO is assigned and ENV is copied (which includes BAZ)
    # 0.25s passes
    # [thread_removing_env] thread resolves and BAZ is removed from env; other_thread still retains knowledge of BAZ
    # 0.25s passes
    # [other_thread] thread resolves, FOO is removed, BAZ is copied back to ENV

    thread_removing_env = Thread.new do
      with_modified_env BAZ: "buzz" do
        sleep 0.5
      end

      expect(ENV["BAZ"]).to be_nil
    end

    other_thread = Thread.new do
      sleep 0.25
      with_modified_env FOO: "bar" do
        sleep 0.5
      end

      expect(ENV["FOO"]).to be_nil
    end

    thread_removing_env.join
    other_thread.join

    expect(ENV["FOO"]).to be_nil
    expect(ENV["BAZ"]).to be_nil
  end

  it "is re-entrant" do
    ret = with_modified_env(FOO: "foo") do
      with_modified_env(BAR: "bar") do
        "bar"
      end
    end

    expect(ret).to eq("bar")

    expect(ENV["FOO"]).to be_nil
    expect(ENV["BAR"]).to be_nil
  end

  it "raises when the value cannot be assigned properly" do
    Thing = Class.new
    message = generate_type_error_for_object(Thing.new)

    expect do
      with_modified_env(FOO: Thing.new)
    end.to raise_error ClimateControl::UnassignableValueError, /attempted to assign .*Thing.* to FOO but failed \(#{message}\)$/
  end

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end

  def generate_type_error_for_object(object)
    message = nil

    begin
      "1" + object
    rescue TypeError => e
      message = e.message
    end

    message
  end

  around do |example|
    old_env = ENV.to_hash

    example.run

    ENV.clear
    old_env.each do |key, value|
      ENV[key] = value
    end
  end
end
