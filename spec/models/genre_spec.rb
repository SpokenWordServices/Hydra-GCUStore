require 'spec_helper'

describe Genre do
  
  it "Should find the genre" do
    @g = Genre.find('Policy or procedure')
    @g.type.should == 'text'
    @g.c_model.should == 'hull-cModel:policy'
  end

  it "Should find all the genres" do
    @g = Genre.find(:all)
    @g.length.should be > 1
    @g.all? { |e| e.kind_of? Genre }.should be_true
  end

end
