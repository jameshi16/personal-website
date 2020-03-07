require 'pathname'

# A DTO for the image url, alt text and caption text
# Line number represents the first line (i.e. the image) this object resides in
# Line 1: Image URL + Alt Text
# Line 2: Caption
class ImageCaption
  attr_accessor(:image_url, :alt_text, :caption, :line_num) # TODO: Forgot about the styling. Woops.

  def initialize(image_url:, alt_text:, caption:, line_num:)
    @image_url = image_url
    @alt_text = alt_text
    @caption = caption
    @line_num = line_num
  end

  def gen_line_1
    return "<img src=\"#{@image_url}\" style=\"max-width: 400px; width: 100%; margin: 0 auto; display: block;\" alt=\"#{@alt_text}\"/>\n"
  end

  def gen_line_2
    return "<p class=\"text-center text-gray lh-condensed-ultra f6\">#{@caption}</p>\n"
  end

  def == other
    return @image_url == other.image_url, @alt_text == other.alt_text, @caption == other.caption, @line_num == other.line_num
  end

  def calculate_absolute_image_url
    return (Pathname.getwd + ("./" + @image_url)).to_s # ensures that image_urls with "/" prepended don't just combust into flames
  end

end
