require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe User do

  describe "a user using no enhanced attribution" do
    before(:each) do
      @user = User.create(:login=>"testuser", :email=> "testuser@example.com", :password=> "password", :password_confirmation => "password")
    end
   
    it "should have a login and email" do
      @user.login.should == "testuser"
      @user.email.should == "testuser@example.com"
    end

    it "should have user attributes methods" do
      @user.should respond_to(:first_name)
      @user.should respond_to(:last_name)
      @user.should respond_to(:full_name)
      @user.should respond_to(:photo)
      @user.should respond_to(:affiliation)
    end

    it "should return blank first_name" do
      @user.first_name.should be_blank
    end
    it "should return blank last_name" do
      @user.last_name.should be_blank
    end
    it "should return blank full_name" do
      @user.full_name.should be_blank
    end
    it "should return blank affiliation" do
      @user.affiliation.should be_blank
    end
    it "should return blank photo" do
      @user.photo.should be_blank
    end
  end

  describe "a user using active record for attribution" do 
    before(:each) do
      @user = User.create(:login => "testuser", :email=>"testuser@example.com", :password => "password", :password_confirmation=>"password")
      ua = UserAttribute.new(:first_name => "Test", :last_name => "User", :affiliation => "Test University", :photo => "test_photo.png", :user_id => @user.id)
      ua.save
    end

    it "should return 'Test' for first_name" do
      @user.first_name.should == 'Test'
    end

    it "should return 'User' for last_name" do
      @user.last_name.should == 'User'
    end

    it "should return 'Test User' for full_name" do
      @user.full_name.should == 'Test User'
    end

    it "should return 'test_photo.png' for photo" do
      @user.photo.should == 'test_photo.png'
    end

    it "should return 'Test University' for affiliation" do
      @user.affiliation.should == 'Test University'
    end
  end
end

module UserTestAttributes
  ['first_name','last_name','full_name','affiliation','photo'].each do |attr|
    class_eval <<-EOM
      def #{attr}
        "test_#{attr}"
      end
    EOM
  end
end
