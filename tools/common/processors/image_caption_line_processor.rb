require 'nokogiri'
require_relative './line_processor'
require_relative '../dto/image_caption_builder'

class ImageCaptionLineProcessor
  include LineProcessor
  attr_reader :imgcaps

  def initialize
    @imgcaps = []
    @builder = ImageCaptionBuilder.new
    @last_good_line = -1
  end

  def self.img_html? line
    /^<img.+>$/.match? line
  end

  def self.caption_html? line
    /^<p.+>$?/.match? line
  end

  def self.extract_img_src line
    Nokogiri::HTML.parse(line).xpath("//img")[0][:src] 
  end
  
  def self.extract_img_alt line
    Nokogiri::HTML.parse(line).xpath("//img")[0][:alt]
  end

  def self.extract_caption line # TODO: Throw exception if //p doesn't exist, standardize the behaviour of all extract_* functions
    Nokogiri::HTML.parse(line).xpath("//p")[0].inner_html
  end

  def process(line_num, line)
    if @builder.nil?
      @builder = ImageCaptionBuilder.new
    end
    
    if ImageCaptionLineProcessor.img_html? line
      @last_good_line = line_num
      @builder.set_image_url(ImageCaptionLineProcessor.extract_img_src line).
        set_alttext(ImageCaptionLineProcessor.extract_img_alt line).
        set_line_num(line_num)
    end

    if @last_good_line != -1 and @last_good_line + 1 == line_num
      if ImageCaptionLineProcessor.caption_html? line
        @builder.set_caption ImageCaptionLineProcessor.extract_caption line 
      else
        @builder.set_caption "" # standalone image, no captions
      end
    end

    if @builder.buildable? # if we've cleared all stages, try and build
      @imgcaps.push(@builder.build)
      @builder = ImageCaptionBuilder.new
    end
    return line
  end
end
