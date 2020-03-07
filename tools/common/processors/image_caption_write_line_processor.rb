require_relative './line_processor'

class ImageCaptionWriteLineProcessor
  include LineProcessor
  attr_reader :imgcaps

  def initialize imgcaps
    @imgcaps = {}
    imgcaps.each { |imgcap|
      @imgcaps[imgcap.line_num] = imgcap
    }
  end

  def process(line_num, line)
    if @imgcaps.has_key? line_num
      imgcap = @imgcaps[line_num]
    elsif @imgcaps.has_key? line_num - 1
      imgcap = @imgcaps[line_num - 1]
    else
      return line
    end

    # intended line is image
    if imgcap.line_num == line_num
      return imgcap.gen_line_1
    end

    # intended line is caption
    if imgcap.line_num + 1 == line_num && imgcap.caption != ""
      return imgcap.gen_line_2
    end

    return line
  end
  
end
