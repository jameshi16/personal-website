require 'time'
require 'fileutils'
require 'pathname'
require './common/processors/image_date_line_processor'

include RSpec

describe ImageDateLineProcessor do

  before(:all) do
    FileUtils.cp_r('./fixtures/input/', './fixtures/.test/')
  end

  expected_dir = Pathname.new './fixtures/expected/'
  tmp_dir = Pathname.new './fixtures/.test/'

  describe "get_dated_image_path_from_line" do
    it 'returns nil if there are no correctly formatted images' do
      expect(ImageDateLineProcessor.get_dated_image_path_from_line "nothing here").to eq(nil) 
    end

    it 'returns the four components if there are correct formatted images' do
      expected_result = DatedImage.new(path: "", date: "20190919", sequence: "29", format: "png")
      expect(ImageDateLineProcessor.get_dated_image_path_from_line "\"20190919_29.png\"").to eq(expected_result)
    end

    it 'returns the four components if there is a path and correctly formatted images' do
      expected_result = DatedImage.new(path: "/i/think/gg/", date: "20190919", sequence: "29", format: "png")
      expect(ImageDateLineProcessor.get_dated_image_path_from_line "\"/i/think/gg/20190919_29.png\"").to eq(expected_result)
    end
  end

  describe "process" do
    idlp = ImageDateLineProcessor.new(Time.parse("2019-06-24 12:39:54 +0800"), tmp_dir)

    it "returns the unmodified line if the string does not contain the dated image" do
      expect(idlp.process(1, "hello world my name is james")).to eq("hello world my name is james")
    end

    it "returns the modified line if the string contains the dated image" do
      expect(idlp.process(2, "blablabla \"20201225_12.png\" blablabla")).to eq("blablabla \"20190624_12.png\" blablabla")

      expected_file = "20190624_12.png"
      expect(FileUtils.compare_file(expected_dir + expected_file, tmp_dir + expected_file)).to eq(true)
    end
  end

  describe "gen_date" do 
    time = Time.parse("2019-06-24 12:39:54 +0800")
    idlp = ImageDateLineProcessor.new(time, tmp_dir)

    it "generate the right date" do
      expect(idlp.gen_date).to eq("20190624")
    end
  end

  after(:all) do
    FileUtils.rm_rf './fixtures/.test'
  end
end
