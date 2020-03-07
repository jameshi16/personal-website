require_relative './dto/image_caption'
require_relative './handlers/get_image_captions_handler'
require_relative './handlers/set_image_captions_handler'

class ImageCaptionFacade
  attr_writer :on_load_images

  def initialize(image, caption_editor)
    if not image.respond_to? :image_url
      raise TypeError.new "#{image} type is not a ImageWidget-like object"
    end

    @index = -1 # uninitalized, not accessible, whatever.
    @image = image
    @caption_editor = caption_editor
  end

  # Lifecycle
  def on_save
    save_current_imgcap
    save
  end

  def on_load
    if @on_load_images
      @on_load_images.call
    end

    if @imgcaps.length > 0
      @index = 0
      on_change @imgcaps[0]
    end
  end

  def on_change img_cap
    @current_imgcap = img_cap
    @image.image_url = img_cap.calculate_absolute_image_url
    @caption_editor.buffer.text = img_cap.caption
  end

  # TODO: def on_replace. should replace the current imgcap.

  def on_next
    if @index < @imgcaps.length - 1
      @index += 1
    end
    on_change @imgcaps[@index]
  end

  def on_previous
    if @index > 0
      @index -= 1
    end
    on_change @imgcaps[@index]
  end

  def next_available?
    @index < @imgcaps.length - 1
  end


  def previous_available?
    @index > 0
  end

  # Utility
  def new_load_handler *args
    GetImageCaptionsHandler.new(*args)
  end

  def from_blog_post path_blog_post
    @path_to_blog_post = path_blog_post
    handler = new_load_handler @path_to_blog_post
    handler.handle

    @imgcaps = handler.imgcaps
    on_load
  end

  def image_url
    @image.image_url
  end

  def caption
    @caption_editor.buffer.text
  end

  def save_current_imgcap
    @current_imgcap.caption = @caption_editor.buffer.text
  end

  def new_save_handler *args
    SetImageCaptionsHandler.new(*args)
  end

  def save
    if not @path_to_blog_post or @path_to_blog_post.empty?
      raise ArgumentError.new "Path to blog post is empty"
    end

    handler = new_save_handler(@path_to_blog_post, @imgcaps)
    handler.handle
  end

end
