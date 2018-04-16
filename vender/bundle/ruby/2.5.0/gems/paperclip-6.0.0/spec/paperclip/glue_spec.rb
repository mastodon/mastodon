# require "spec_helper"

describe Paperclip::Glue do
  describe "when ActiveRecord does not exist" do
    before do
      ActiveRecordSaved = ActiveRecord
      Object.send :remove_const, "ActiveRecord"
    end

    after do
      ActiveRecord = ActiveRecordSaved
      Object.send :remove_const, "ActiveRecordSaved"
    end

    it "does not fail" do
      NonActiveRecordModel = Class.new
      NonActiveRecordModel.send :include, Paperclip::Glue
      Object.send :remove_const, "NonActiveRecordModel"
    end
  end

  describe "when ActiveRecord does exist" do
    before do
      if Object.const_defined?("ActiveRecord")
        @defined_active_record = false
      else
        ActiveRecord = :defined
        @defined_active_record = true
      end
    end

    after do
      if @defined_active_record
        Object.send :remove_const, "ActiveRecord"
      end
    end

    it "does not fail" do
      NonActiveRecordModel = Class.new
      NonActiveRecordModel.send :include, Paperclip::Glue
      Object.send :remove_const, "NonActiveRecordModel"
    end
  end
end
