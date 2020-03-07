require_relative './image_caption_facade'
require_relative './image_navigation_buttons_facade'

class SignalCallbackFacade
  attr_reader :image
  attr_reader :caption_editor
  attr_reader :button_prev
  attr_reader :button_next
  attr_reader :button_save
  attr_reader :button_replace

  def initialize(window, image, caption_editor, button_prev, button_next, button_save, button_repl)
    @window = window
    @image = image
    @caption_editor = caption_editor
    @button_prev = button_prev
    @button_next = button_next
    @button_save = button_save
    @button_replace = button_repl 

    @image_caption_facade = new_image_caption_facade
    @image_navigation_buttons_facade = new_image_navigation_buttons_facade 
  end

  def new_image_caption_facade
    ImageCaptionFacade.new(@image, @caption_editor)
  end

  def new_image_navigation_buttons_facade
    ImageNavigationButtonsFacade.new(@image_caption_facade, @button_prev, @button_next, @button_save, @button_replace)
  end

  def load_images_from_blog_post filename
    @image_caption_facade.from_blog_post filename
  end

  def attach_signal_callbacks
    @image_navigation_buttons_facade.attach_signal_callbacks 
  end

  def attach_accel_groups
    # TODO: Implement
    # Arrow keys should call the next and previous functions
    # CTRL + S should call the save functions
    # CTRL + R should call the replace function
  end

end
