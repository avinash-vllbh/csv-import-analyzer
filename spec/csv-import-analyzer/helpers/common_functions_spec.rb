# require 'spec_helper'

class DummyClass
end

describe CsvImportAnalyzer::Helper do
  describe "#null_like?" do
    before(:each) do
      @dummy_class = DummyClass.new
      @dummy_class.extend(CsvImportAnalyzer::Helper)
    end

    context "when called on null like objects" do
      it "returns NULL as null type" do
        expect(@dummy_class.null_like?("NULL")).to eq(true)
      end

      it "returns \\N as null type" do
        expect(@dummy_class.null_like?('\N')).to eq(true)
      end
    end

    context "when called on non-null objects" do
      it "returns hello as not null" do
        expect(@dummy_class.null_like?("Hello")).to eq(false)
      end
      it "returns Fixnum(3) as not null" do
        expect(@dummy_class.null_like?(3)).to eq(false)
      end
    end
  end
end