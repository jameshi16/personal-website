require 'pathname'
require './common/dto/image_caption'
include RSpec

describe ImageCaption do
  ic = ImageCaption.new(image_url: "yes", alt_text: "enjoying", caption: "yourself?", line_num: 123)
  
  it "#gen_line_1" do
    expect(ic.gen_line_1).to eq("<img src=\"yes\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"enjoying\"/>\n")
  end

  it "#gen_line_2" do
    expect(ic.gen_line_2).to eq("<p class=\"text-center text-gray lh-condensed-ultra f6\">yourself?</p>\n")
  end

  it "#calculate_absolute_image_url" do
    expect(ic.calculate_absolute_image_url).to include(Pathname.getwd.to_s)
    expect(ic.calculate_absolute_image_url).to include(ic.image_url)
  end

end
