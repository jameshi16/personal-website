require './common/dto/image_caption'
require './common/dto/image_caption_builder'

include RSpec

describe ImageCaptionBuilder do
 describe "#initialize" do
   icb = ImageCaptionBuilder.new

   it "is at stage 0" do 
     expect(icb.stage).to eq(0) 
   end

   it "cannot be built" do
     expect{ icb.build }.to raise_error('builder not in the proper stage')
   end
 end 

 describe "set_stage!" do
   icb = ImageCaptionBuilder.new

   it "set stage bit 0" do
    icb.set_stage! 0
    expect(icb.stage).to eq(1)
   end

   it "allows stage to increase" do
     icb.set_stage! 1
     expect(icb.stage).to eq(3)
   end

   it "but does not allow it to decrease" do
     icb.set_stage! 2
     expect(icb.stage).to eq(7)
   end
 end

 describe "build" do
   it "gets built after all the fields are set" do 
     icb = ImageCaptionBuilder.new
     icb.set_image_url("interesting").set_alttext("art").set_caption("you've got there").set_line_num(123)
     expect(icb.build).to eq(ImageCaption.new(image_url: "interesting",
                                              alt_text: "art",
                                              caption: "you've got there",
                                              line_num: 123))
   end

   it "does not get build if not all the fields have been set" do
     icb = ImageCaptionBuilder.new
     icb.set_alttext("art").set_alttext("art").set_alttext("art")
     expect{ icb.build }.to raise_error('builder not in the proper stage')
   end

  describe "buildable?" do

    it "is buildable when all stages are cleared" do
      icb = ImageCaptionBuilder.new
      icb.set_stage! 0
      icb.set_stage! 1
      icb.set_stage! 2
      icb.set_stage! 3

      expect(icb.buildable?).to eq(true)
    end

    it "is not buildable when not all stages are cleared" do
      icb = ImageCaptionBuilder.new
      icb.set_stage! 2

      expect(icb.buildable?).to eq(false)
    end

  end

 end
end
