# Wraps around the GTK image widget, only accepting a filename.

require "gtk2"

require_relative "./gui_utils"

class ImageWidget < Gtk::Image
  attr_reader :image_url
  attr_reader :placeholder_width
  attr_reader :placeholder_height

  def initialize image_url
    super
    @placeholder_width = 300
    @placeholder_height = 300

    self.image_url = image_url
  end

  def placeholder_width= width
    if not width.is_a? Integer
      raise TypeError.new "width must be an integer type, got #{width}"
    end

    @placeholder_width = width
    draw_black_box 
  end

  def placeholder_height= height
    if not height.is_a? Integer
      raise TypeError.new "height must be an integer type, got #{height}"
    end

    @placeholder_height = height
    draw_black_box
  end
    
  def image_url= image_url
    if image_url.empty?
      @image_url = ""
      draw_black_box
      return
    end

    if not File.exist? image_url
      raise ArgumentError.new "#{image_url} does not exist" 
    end   
    
    @image_url = image_url   
    self.file = @image_url
  end

  private

  def draw_block_box!
    self.pixmap = black_box(@placeholder_width, @placeholder_height)
  end

  def draw_black_box
    if @image_url.empty?
      draw_block_box!
    end
  end

end
