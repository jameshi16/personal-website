require_relative './handler'
require_relative '../processors/image_caption_line_processor'

class GetImageCaptionsHandler
  include Handler
  attr_accessor :imgcaps
  
  def initialize filename
    @filename = filename
    @imgcap_processor = ImageCaptionLineProcessor.new
    @processors = [@imgcap_processor]
    @imgcaps = []
  end

  def handle
    if not File.exist?(@filename)
      return
    end

    IO.foreach(@filename).with_index { |line, line_num|
      self.do_process(line_num, line)
    } 

    @imgcaps = @imgcap_processor.imgcaps
  end
end
