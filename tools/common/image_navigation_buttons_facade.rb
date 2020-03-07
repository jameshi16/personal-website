class ImageNavigationButtonsFacade
  attr_reader :button_prev
  attr_reader :button_next
  attr_reader :button_save
  attr_reader :button_replace

  def initialize(image_caption_facade, button_prev, button_next, button_save, button_replace)
    @image_caption_facade = image_caption_facade
    @button_prev = button_prev
    @button_next = button_next
    @button_save = button_save
    @button_replace = button_replace

    @image_caption_facade.on_load_images = Proc.new do 
      self.update_button_state
    end
  end

  def on_previous
    @image_caption_facade.on_previous
    update_button_state
  end

  def on_next
    @image_caption_facade.on_next
    update_button_state
  end

  def on_save
     @image_caption_facade.on_save
     update_button_state
  end

  def on_replace
    # need a replacement dialog flow here
    # 1) open file picker dialog
    # 2) choose new image
    # 3) replace the image within the image caption
  end

  def update_button_state
    @button_replace.sensitive = false # TODO: Re-enable when replacement is implemented

    @button_next.sensitive = @image_caption_facade.next_available?
    @button_prev.sensitive = @image_caption_facade.previous_available?
  end
  
  def attach_signal_callbacks
    @button_prev.signal_connect("clicked") {
      on_previous
    }

    @button_next.signal_connect("clicked") {
      on_next
    }

    @button_save.signal_connect("clicked") {
      on_save
    }

    @button_replace.signal_connect("clicked") {
      on_replace
    }
  end

end
