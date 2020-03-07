require "./common/signal_callback_facade"

include RSpec

class ImageCaptionFacadeMock
  attr_accessor :image
  attr_accessor :caption_editor
  attr_accessor :blog_post

  def initialize(image, caption_editor)
    @image = image
    @caption_editor = caption_editor
  end

  def from_blog_post(blog_post)
    @blog_post = blog_post
  end
end

class ImageNavigationButtonsFacadeMock
  attr_accessor :image_caption_facade
  attr_accessor :button_prev
  attr_accessor :button_next
  attr_accessor :button_save
  attr_accessor :button_replace
  attr_accessor :attach_signal_callbacks

  def initialize(image_caption_facade, button_prev, button_next, button_save, button_replace)
    @image_caption_facade = image_caption_facade
    @button_prev = button_prev
    @button_next = button_next
    @button_save = button_save
    @button_replace = button_replace
    @attach_signal_callbacks = false
  end

  def attach_signal_callbacks
    @attach_signal_callbacks = true 
  end
end

class SignalCallbackFacadeWithMock < SignalCallbackFacade
  attr_reader :window
  attr_reader :image_caption_facade
  attr_reader :image_navigation_buttons_facade

  def new_image_caption_facade
    ImageCaptionFacadeMock.new(@image, @caption_editor) 
  end

  def new_image_navigation_buttons_facade
    ImageNavigationButtonsFacadeMock.new(@image_caption_facade, @button_prev, @button_next, @button_save, @button_replace)
  end
end

describe SignalCallbackFacade do
  scf = SignalCallbackFacadeWithMock.new(1, 2, 3, 4, 5, 6, 7)
  
  it "assigns the parameters to fields correctly" do
    expect(scf.window).to eq(1)
    expect(scf.image).to eq(2)
    expect(scf.caption_editor).to eq(3)
    expect(scf.button_prev).to eq(4)
    expect(scf.button_next).to eq(5)
    expect(scf.button_save).to eq(6)
    expect(scf.button_replace).to eq(7)

    expect(scf.image_caption_facade.image).to eq(2)
    expect(scf.image_caption_facade.caption_editor).to eq(3)
    
    expect(scf.image_navigation_buttons_facade.button_prev).to eq(4)
    expect(scf.image_navigation_buttons_facade.button_next).to eq(5)
    expect(scf.image_navigation_buttons_facade.button_save).to eq(6)
    expect(scf.image_navigation_buttons_facade.button_replace).to eq(7)
  end 

  it "propogates the attach_signal_callbacks call to the image_navigation_buttons_facade" do
    scf.attach_signal_callbacks

    expect(scf.image_navigation_buttons_facade.attach_signal_callbacks).to eq(true)
  end

  it "propogates the load_images_from_blog_post call to from_blog_post call of image_caption_facade" do
    scf.load_images_from_blog_post "test"

    expect(scf.image_caption_facade.blog_post).to eq("test")
  end
end
