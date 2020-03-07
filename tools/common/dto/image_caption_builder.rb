# A builder for the ImageCaption DTO.

require_relative './image_caption'

class ImageCaptionBuilder
  attr_reader :stage

  def initialize
    @stage = 0
  end

  def set_stage! bit
    @stage = @stage | (1 << bit)
  end

  def set_image_url image_url
    @image_url = image_url
    self.set_stage! 0
    return self
  end

  def set_line_num line_num
    @line_num = line_num
    self.set_stage! 1
    return self
  end

  def set_alttext alttext
    @alttext = alttext
    self.set_stage! 2
    return self
  end

  def set_caption caption
    @caption = caption
    self.set_stage! 3
    return self
  end

  def build
    if not self.buildable?
      raise 'builder not in the proper stage'
    end

    return ImageCaption.new(image_url: @image_url,
                            alt_text: @alttext,
                            caption: @caption,
                            line_num: @line_num)
  end

  def buildable?
    @stage & 0b1111 == 0b1111
  end
  
end
