require 'fileutils'
require 'pathname'

require './common/dto/image_caption_builder.rb'
require './common/handlers/set_image_captions_handler.rb'

include RSpec

describe SetImageCaptionsHandler do
  before(:all) do
    FileUtils.cp_r("./fixtures/input", "./fixtures/.test")
  end

  describe "replaces the right lines in the file" do
    filename = "2020-02-16-image-captions.md"
    test_dir = Pathname.new "./fixtures/.test"
    expected_dir = Pathname.new "./fixtures/expected"

    img_cap_1 = ImageCaptionBuilder.new
    img_cap_2 = ImageCaptionBuilder.new

    img_cap_1.set_image_url("test1.png").set_alttext("a test").set_line_num(9).set_caption("yup, captions")
    img_cap_2.set_image_url("test2.png").set_alttext("a test 2").set_line_num(14).set_caption("yay captions")

    sich = SetImageCaptionsHandler.new(test_dir + filename, [img_cap_1.build, img_cap_2.build])
    it "updates the file correctly" do
      sich.handle

      expect(FileUtils.compare_file(test_dir + filename, expected_dir + filename)).to eq(true)
    end
  end 

  after(:all) do
    FileUtils.rm_rf(["./fixtures/.test"])
  end
end
