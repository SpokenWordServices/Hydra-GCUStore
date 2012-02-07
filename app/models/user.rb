class User < ActiveRecord::Base
   has_and_belongs_to_many :roles
  # Connects this user object to Blacklights Bookmarks and Folders. 
  include Blacklight::User
  include Hydra::User

  before_save :get_user_attributes
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable

  devise :cas_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :username

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account. 
  def to_s
    username  
  end

  private

  def get_user_attributes
    person = ActiveRecord::Base.connection.select_one('SELECT * FROM person WHERE user_name="' + username.to_s + '"')

    user_type = "guest"
    email = "guest@hydraathull.ac.uk"

    if !person.nil? 
     if !person["type"].nil? then user_type =  person["type"] end
     if !person["EmailAddress"].nil? then email = person["EmailAddress"] end
    end

    self.email = email
    update_user_role(user_type)
  end

  def update_user_role (user_type)
   #If the role exists in the local database use it (staff/student/guest), otherwise turn to guest... 
   #Later throw exception, log, and set to guest... 
   if Role.find_or_initialize_by_name(user_type).persisted? then role =  Role.find_or_initialize_by_name(user_type) else role = Role.find_or_initialize_by_name("guest") end
		
   #Does this role exist in the current table...
   if !self.roles.include?(role)
     #If the self has roles in it already delete older roles from self 	   
     if !self.roles.empty? then delete_standard_roles_from_user end			
     self.roles << role 
   end
  end

  #Use this method to remove all staff/student/guest roles from a user
  def delete_standard_roles_from_user
    standard_roles = []
    ["staff", "student", "guest"].each {|r| standard_roles << Role.find_or_initialize_by_name(r) } 

    self.roles.each do |role|
      if standard_roles.include?(role)
        #delete the role
        self.roles.delete(role)
      end
    end		
  end

end
