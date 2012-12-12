module UserHelper
  def cat_user_sign_in 
    delete_all_users 
    #Create the user
    @user = User.create!(:username => "contentAccessTeam1", :email => "contentAccessTeam1@example.com")
    #Add the role
    @user.roles = [Role.find_or_initialize_by_name("contentAccessTeam")]
    sign_in :user, @user
  end
  def student_user_sign_in 
    delete_all_users 
    #Create the user
    @user = User.create!(:username => "student1", :email => "student1@example.com", :password =>"password")
    #Add the role
    @user.roles = [Role.find_or_initialize_by_name("student")]
    sign_in :user, @user
  end
  def delete_all_users
    User.delete_all 
  end
  def load_roles
   ["contentAccessTeam", "staff", "student", "committeeSection", "engineering"].each {|r| Role.create(:name => r, :description => r) } 
  end 

end
