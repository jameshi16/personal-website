require './common/dto/dated_image'

include RSpec

describe DatedImage do
  di = DatedImage.new(path: "_images/", date: "20190917", sequence: "28", format: "png")

  it "forms the correct string" do
    expect(di.to_str).to eq("\"_images/20190917_28.png\"")
  end
end
