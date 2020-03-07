require './common/dto/image_caption'
require './common/handlers/get_image_captions_handler'

include RSpec

describe GetImageCaptionsHandler do
  gich = GetImageCaptionsHandler.new "./fixtures/input/2020-02-16-image-captions.md"

  it "can get the image captions correctly" do
    gich.handle

    imgcap_1 = ImageCaption.new(image_url: "20200216_1.png",
                                 alt_text: "Interesting Image",
                                 caption: "Caption is a thing",
                                 line_num: 10)

    imgcap_2 = ImageCaption.new(image_url: "20200216_2.png",
                                 alt_text: "Another Image",
                                 caption: "youtube is clickbait",
                                 line_num: 15)


    expect(gich.imgcaps).to eq([imgcap_1, imgcap_2])
  end
end
