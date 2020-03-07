require './common/dto/image_caption'
require './common/processors/image_caption_write_line_processor'
include RSpec

describe ImageCaptionWriteLineProcessor do

 describe "initialize" do
  it "initializes imgcaps correctly" do
    imcap = ImageCaption.new(image_url: "urlmuchwow", alt_text: "data", caption: "james forgets another thing colorized 2019", line_num: 1)
    icwlp = ImageCaptionWriteLineProcessor.new [imcap]

    expect(icwlp.imgcaps).to eq({1 => imcap})
  end
 end

 describe "#process" do
  it "replaces the right things" do
    imcap = ImageCaption.new(image_url: "urlmuchwow", alt_text: "data", caption: "james forgets another thing colorized 2019", line_num: 1)
    icwlp = ImageCaptionWriteLineProcessor.new [imcap]

    expect(icwlp.process(1, "please replace me senpai")).to eq(imcap.gen_line_1)
    expect(icwlp.process(2, ":D")).to eq(imcap.gen_line_2)
  end

  it "does not generate caption for empty captions" do
    imcap = ImageCaption.new(image_url: "urlmuchwow", alt_text: "data", caption: "", line_num: 1)
    icwlp = ImageCaptionWriteLineProcessor.new [imcap]

    expect(icwlp.process(1, "please replace me senpai")).to eq(imcap.gen_line_1)
    expect(icwlp.process(2, ":D")).to eq(":D")
  end
 end 

end
