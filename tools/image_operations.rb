#!/usr/bin/ruby
# Interface front for image operations

require 'gtk2'

require_relative './common/gui_utils'
require_relative './common/image_widget'
require_relative './common/signal_callback_facade'

# Need: (i) argument, and (ii) argument is valid filename
def help *error_msg
  puts error_msg if error_msg and not error_msg.empty?
  puts "Usage: #{$0} <path to blog post>"
  puts "Loads all the images available in the blog post"
  exit
end

help "no argument" if $*.length < 1
help "file not found" if not File.exist? $*[0]

# The interface would need:
# (i) An image
# (ii) Textbox for caption editing
# (iii) A button bar with previous, next, save, and replace

# the objects themselves
image = ImageWidget.new ""
caption_editor = Gtk::TextView.new

button_prev = Gtk::Button.new "Previous"
button_next = Gtk::Button.new "Next"
button_save = Gtk::Button.new "Save"
button_repl = Gtk::Button.new "Replace"

# layout
buttons_box = Gtk::HBox.new(false, 0)
buttons_box.pack_start(button_prev, true, true, 2)
buttons_box.pack_start(button_next, true, true, 2)
buttons_box.pack_start(button_save, true, true, 2)
buttons_box.pack_start(button_repl, true, true, 2)

separator = Gtk::HSeparator.new

full_vbox = Gtk::VBox.new(false, 0)
full_vbox.pack_start(image, true, true, 0)
full_vbox.pack_start(caption_editor, true, true, 0)
full_vbox.pack_start(separator, true, true, 0)
full_vbox.pack_start(buttons_box, true, true, 0)

# create the window
window = Gtk::Window.new "Image Operations"
window.add full_vbox
window.show_all
window.signal_connect("destroy") {
  Gtk.main_quit
}

# signal callbacks
signal_callback_facade = SignalCallbackFacade.new(window, image, caption_editor, button_prev, button_next, button_save, button_repl)
signal_callback_facade.attach_signal_callbacks
signal_callback_facade.load_images_from_blog_post $*[0] 

# start the gui
Gtk.main
