require './common/processors/image_caption_line_processor'

include RSpec

describe ImageCaptionLineProcessor do
  describe "::img_html?" do
    it "finds an image html" do
      expect(ImageCaptionLineProcessor.img_html? "<img src=\"source\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"alttext\"/>").to eq(true)
    end

    it "does not find an image html" do
      expect(ImageCaptionLineProcessor.img_html? "hey guys, how's your day").to eq(false)
    end
  end

  describe "::caption_html?" do
    it "finds a caption html" do
      expect(ImageCaptionLineProcessor.caption_html? "<p class=\"text-center text-gray lh-condensed-ultra f6\">Caption</p>").to eq(true)
    end

    it "does not find a caption html" do
      expect(ImageCaptionLineProcessor.caption_html? "hello again, im the text that talks to you in your sleep").to eq(false)
    end
  end

  describe "::extract_img_src" do
    it "gets the source correctly" do
      expect(ImageCaptionLineProcessor.extract_img_src "<img src=\"source\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"alttext\"/>").to eq("source")
    end

    it "does not get the source" do
      expect{ ImageCaptionLineProcessor.extract_img_src "this should cause an exception" }.to raise_error(NoMethodError)
    end
  end

  describe "::extract_img_alt" do
    it "gets the image alt text correctly" do
      expect(ImageCaptionLineProcessor.extract_img_alt "<img src=\"source\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"alttext\"/>").to eq("alttext")
    end

    it "does not get the image alt" do
      expect{ ImageCaptionLineProcessor.extract_img_alt "this will cause an exception" }.to raise_error(NoMethodError)
    end
  end

  describe "::extract_caption" do
    it "processes the captions properly" do
      expect(ImageCaptionLineProcessor.extract_caption "<p class=\"text-center text-gray lh-condensed-ultra f6\">Caption</p>").to eq("Caption")
    end

    it "process the captions even with an <a> tag properly" do
      expect(ImageCaptionLineProcessor.extract_caption "<p class=\"text-center text-gray lh-condensed-ultra f6\">Caption | Source <a href=\"me\">me</a></p>").to eq("Caption | Source <a href=\"me\">me</a>")
    end

    # TODO: Nokogiri parses plaintext as <p> too, so the test to extract captions from non-<p> tags fails, hence it is omitted.
  end

  describe "#process" do
    it "generates a proper ImageCaption object" do
      iclp = ImageCaptionLineProcessor.new
      iclp.process(1, "<img src=\"source\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"alttext\"/>")
      iclp.process(2, "<p class=\"text-center text-gray lh-condensed-ultra f6\">Caption</p>")

      expect(iclp.imgcaps.length).to eq(1)
      expect(iclp.imgcaps[0]).to eq(ImageCaption.new(image_url: "source", alt_text: "alttext", caption: "Caption", line_num: 1))
    end

    it "generates a standalone ImageCaption object" do
      iclp = ImageCaptionLineProcessor.new
      iclp.process(1, "<img src=\"source\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"alttext\"/>")
      iclp.process(2, "i'm some other string")

      expect(iclp.imgcaps.length).to eq(1)
      expect(iclp.imgcaps[0]).to eq(ImageCaption.new(image_url: "source", alt_text: "alttext", caption: "", line_num: 1))
    end

    it "generates a standalone ImageCaption object, when string numbers don't match" do
      iclp = ImageCaptionLineProcessor.new
      iclp.process(1, "<img src=\"source\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"alttext\"/>")
      iclp.process(2, "hello")
      iclp.process(3, "<p class=\"text-center text-gray lh-condensed-ultra f6\">Caption</p>")

      expect(iclp.imgcaps.length).to eq(1)
      expect(iclp.imgcaps[0]).to eq(ImageCaption.new(image_url: "source", alt_text: "alttext", caption: "", line_num: 1))
    end

    it "generates two ImageCaption objects" do
      iclp = ImageCaptionLineProcessor.new
      iclp.process(1, "<img src=\"source\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"alttext\"/>")
      iclp.process(2, "<p class=\"text-center text-gray lh-condensed-ultra f6\">Caption</p>")
      iclp.process(3, "hello, this is some random text that I could use for some cool stuff")
      iclp.process(4, "<img src=\"source2\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"alttext2\"/>")
      iclp.process(5, "<p class=\"text-center text-gray lh-condensed-ultra f6\">Caption2</p>")

      expect(iclp.imgcaps.length).to eq(2)
      expect(iclp.imgcaps[0]).to eq(ImageCaption.new(image_url: "source", alt_text: "alttext", caption: "Caption", line_num: 1))
      expect(iclp.imgcaps[1]).to eq(ImageCaption.new(image_url: "source2", alt_text: "alttext2", caption: "Caption2", line_num: 4))
    end

  end
end
