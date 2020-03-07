require 'time'
require './common/processors/date_metadata_line_processor'

include RSpec

describe DateMetadataLineProcessor do

  describe "is_date?" do
    it 'returns true when it sees a date in a string' do
      expect(DateMetadataLineProcessor.is_date? "thingy thing thing 2019-04-03 07:59 +08:00 thing").to eq(true)
    end 

    it 'returns true when there is only a date in a string' do
      expect(DateMetadataLineProcessor.is_date? "2019-04-03 07:59 +08:00 thing").to eq(true)
    end

    it 'returns false when it does not see date in a string' do
      expect(DateMetadataLineProcessor.is_date? "nothing interesting here").to eq(false)
    end

    it 'returns false when there is not a string' do
      expect(DateMetadataLineProcessor.is_date? "").to eq(false)
    end
  end 

 describe "is_date_metadata?" do
  it "returns true if the string is a date metadata" do
    expect(DateMetadataLineProcessor.is_date_metadata? "date: 2020-09-17 09:00 +08:00\n").to eq(true)
  end

  it "returns false if the string is not it's own line" do
    expect(DateMetadataLineProcessor.is_date_metadata? "date: 2020-09-17 09:00 +08:00 hello").to eq(false)
  end

  it "returns false if the string has stuff in front of the date" do
    expect(DateMetadataLineProcessor.is_date_metadata? "nope date: 2020-09-17 09:00 +08:00\n").to eq(false)
  end

  it "returns false if the string is other things" do
    expect(DateMetadataLineProcessor.is_date_metadata? "no its not").to eq(false)
  end
 end 

 describe "process" do
   dmlp = DateMetadataLineProcessor.new Time.parse "2019-06-24 12:39:54 +0800"

   it "returns the unmodified line if the string does not contains date metadata" do
    expect(dmlp.process(1, "hello world my name is james")).to eq("hello world my name is james")
   end

   it "returns the modified line if the string contains date metadata" do
    expect(dmlp.process(2, "date: 2020-09-17 09:00 +08:00\n")).to eq("date: 2019-06-24 12:00 +08:00\n")
   end
 end
end
