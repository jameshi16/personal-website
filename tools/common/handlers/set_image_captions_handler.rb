require 'tempfile'

require_relative './handler'
require_relative '../processors/image_caption_write_line_processor'

class SetImageCaptionsHandler
  include Handler
  
  def initialize(filename, imgcaps)
    @filename = filename
    @processors = [ImageCaptionWriteLineProcessor.new(imgcaps)]
  end

  def handle
    if not File.exist?(@filename)
      return
    end

    Tempfile.create('ich') { |tmp|
      IO.foreach(@filename).with_index { |line, line_num|
        tmp.write self.do_process(line_num, line)
      }

      tmp.rewind
      IO.copy_stream(tmp, @filename)
    }

  end
end
