require 'spec_helper'

describe MeetingPaper do
  before do
    @meeting_paper = MeetingPaper.new
  end
  describe "apply_additional_metadata" do
    before do
      @desc_ds = @meeting_paper.datastreams_in_memory["descMetadata"]
      @desc_ds.update_indexed_attributes({[:title] => ["My title"]})
    end
    it "should copy the date from the descMetadata to the dc datastream if it is present" do
      @desc_ds.update_indexed_attributes({[:origin_info, :date_issued] => ['2011-10']})
      @meeting_paper.apply_additional_metadata(123).should == true
      @meeting_paper.datastreams_in_memory["DC"].dc_title.should == ["My title"]
      pending  #It's using Hydra::ModsMeetingPaper which doesn't have [:origin_info,:date_issued]
      @meeting_paper.datastreams_in_memory["DC"].dc_dateIssued.should == ['2011-10']
    end
    it "should not copy the date from the descMetadata to the dc datastream if it isn't present" do
      @meeting_paper.apply_additional_metadata(123).should == true
      @meeting_paper.datastreams_in_memory["DC"].dc_dateIssued.should == [""]
      @meeting_paper.datastreams_in_memory["DC"].dc_title.should == ["My title"]
    end
  end
end


