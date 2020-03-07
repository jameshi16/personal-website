require 'gtk2'
require './common/dto/image_caption'
require './common/handlers/handler'
require './common/image_widget'
require './common/image_caption_facade'

include RSpec

# overrides new_load/save_handler for testing
class MockHandler
  include Handler
  attr_accessor :success
  attr_accessor :imgcaps

  def initialize
    self.imgcaps = []
    self.success = false
  end

  def handle
    self.success = true
  end 
end

class ImageCaptionFacadeWithMock < ImageCaptionFacade
  attr_reader :save_handler
  attr_reader :load_handler
  
  def new_save_handler *args
    if not @save_handler
      @save_handler = MockHandler.new 
    end

    @save_handler
  end

  def new_load_handler *args
    if not @load_handler
      @load_handler = MockHandler.new
    end

    @load_handler
  end
end

# helper function to generate generic boilerplate for testing
def generate_generic_facade image_file
    img_widget = ImageWidget.new image_file
    caption_editor = Gtk::TextView.new
    
    img_cap = ImageCaption.new(image_url: image_file, 
                               alt_text: "", 
                               caption: "fun people doing fun things",
                               line_num: 1)

    imcf = ImageCaptionFacadeWithMock.new(img_widget, caption_editor)
    imcf.on_change img_cap
    return {:img_widget => img_widget, :caption_editor => caption_editor, :img_cap => img_cap, :imcf => imcf}
end

describe ImageCaptionFacade do describe :initialize do
    image_fixture_path = "./fixtures/input/gods_memopad.jpg"
    it "initializes with a ImageWidget-like object" do
      img_widget = ImageWidget.new image_fixture_path
      caption_editor = Gtk::TextView.new

      ImageCaptionFacade.new(img_widget, caption_editor)
    end

    it "does not initialize with a non-ImageWidget-like object" do
      img_widget = Gtk::Image.new image_fixture_path 

      # second parameter doesn't matter in this test
      expect{ImageCaptionFacade.new(img_widget, nil)}.to raise_error(TypeError)
    end
  end

  describe :on_change do
    from_img_cap = ImageCaption.new(image_url: "./fixtures/input/gods_memopad.jpg", 
                                    alt_text: "", 
                                    caption: "fun people doing fun things",
                                    line_num: 1)
    to_img_cap = ImageCaption.new(image_url: "./fixtures/input/computer.jpg", 
                                  alt_text: "",
                                  caption: "why am i still here",
                                  line_num: 1)

    img_widget = ImageWidget.new from_img_cap.image_url
    caption_editor = Gtk::TextView.new
    caption_editor.buffer.text = from_img_cap.caption

    imcf = ImageCaptionFacade.new(img_widget, caption_editor)

    it "transitions from ImageCaption to another properly" do
      imcf.on_change to_img_cap
      expect(imcf.image_url).to eq(to_img_cap.calculate_absolute_image_url)
      expect(imcf.caption).to eq(to_img_cap.caption)
    end
  end

  describe :save_current_imgcap do
    image_file = "./fixtures/input/gods_memopad.jpg"
    objects = generate_generic_facade image_file
    imcf = objects[:imcf]
    caption_editor = objects[:caption_editor]
    image_cap = objects[:img_cap]

    it "saves the modified image caption" do
      expect(imcf.image_url).to eq(image_cap.calculate_absolute_image_url)
      expect(imcf.caption).to eq("fun people doing fun things")

      caption_editor.buffer.text = "new stuff" 
      imcf.save_current_imgcap
      
      expect(imcf.caption).to eq("new stuff")
      expect(image_cap.caption).to eq("new stuff")
    end
  end

  describe :from_blog_post do
    image_file = "./fixtures/input/gods_memopad.jpg"
    objects = generate_generic_facade image_file
    imcf = objects[:imcf]
    imgcap = objects[:img_cap]

    it "calls the handler to load the file, but does not call on_change" do
      imcf.from_blog_post "doesn't matter"

      expect(imcf.load_handler.success).to eq(true)
      expect(imcf.image_url).to eq(imgcap.calculate_absolute_image_url)
      expect(imcf.caption).to eq("fun people doing fun things")
    end

    it "calls the handler to load the file, and calls on_change" do
      new_image_url = "./fixtures/input/computer.jpg"
      to_img_cap = ImageCaption.new(image_url: new_image_url, 
                                   alt_text: "",
                                   caption: "why am i still here",
                                   line_num: 1)
      imcf.load_handler.imgcaps = [to_img_cap]
      imcf.from_blog_post "doesn't matter"
      
      expect(imcf.load_handler.success).to eq(true)
      expect(imcf.image_url).to eq(to_img_cap.calculate_absolute_image_url)
      expect(imcf.caption).to eq("why am i still here")
    end
  end
  
  describe :save do
    image_file = "./fixtures/input/gods_memopad.jpg"
    objects = generate_generic_facade image_file
    
    it "throws an exception if saving is done before loading" do
      img_widget = ImageWidget.new image_file
      caption_editor = Gtk::TextView.new
      imcf = ImageCaptionFacadeWithMock.new(img_widget, caption_editor)

      expect{imcf.save}.to raise_error(ArgumentError)
    end

    it "throws an exception if saving is done before loading, and string is empty for some reason" do
      img_widget = ImageWidget.new image_file
      caption_editor = Gtk::TextView.new
      imcf = ImageCaptionFacadeWithMock.new(img_widget, caption_editor)

      imcf.from_blog_post ""
      
      expect{imcf.save}.to raise_error(ArgumentError)
    end

    it "saves properly" do
      imcf = objects[:imcf]

      imcf.from_blog_post "valid, doesn't matter"
      imcf.save
      expect(imcf.save_handler.success).to eq(true)
    end 
  end
  
  describe :on_save do
    image_file = "./fixtures/input/gods_memopad.jpg"
    objects = generate_generic_facade image_file 
    
    it "saves properly" do
      imcf = objects[:imcf]

      imcf.from_blog_post "valid, doesn't matter"
      imcf.save
      expect(imcf.save_handler.success).to eq(true)
    end  
  end

  describe "on_next, on_previous, next_available?, previous_available?" do
    img_cap_1 = ImageCaption.new(image_url: "./fixtures/input/gods_memopad.jpg", 
                                    alt_text: "", 
                                    caption: "fun people doing fun things",
                                    line_num: 1)
    img_cap_2 = ImageCaption.new(image_url: "./fixtures/input/computer.jpg", 
                                  alt_text: "",
                                  caption: "why am i still here",
                                  line_num: 1)
    image_file = "./fixtures/input/gods_memopad.jpg"
    objects = generate_generic_facade image_file 
    imcf = objects[:imcf]

    imcf.new_load_handler "doesn't matter"
    imcf.load_handler.imgcaps = [img_cap_1, img_cap_2] # load two image captions so we can actually test things
    imcf.from_blog_post "doesn't matter"
    
    it "next available, previous not available, on next changes to img_cap_2, next not available, previous available" do
      expect(imcf.next_available?).to eq(true)
      expect(imcf.previous_available?).to eq(false)
      expect(imcf.caption).to eq("fun people doing fun things")

      imcf.on_next

      expect(imcf.next_available?).to eq(false)
      expect(imcf.previous_available?).to eq(true)
      expect(imcf.caption).to eq("why am i still here")
    end

    it "next not available, previous available, on previous changes to img_cap_1, next available, previous not available" do
      expect(imcf.next_available?).to eq(false)
      expect(imcf.previous_available?).to eq(true)
      expect(imcf.caption).to eq("why am i still here")

      imcf.on_previous

      expect(imcf.next_available?).to eq(true)
      expect(imcf.previous_available?).to eq(false)
      expect(imcf.caption).to eq("fun people doing fun things")
    end
  end
end
