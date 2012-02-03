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

  def display_text
		debugger
		email[0..email.index('@') -1]	
  end

  private

  def get_user_attributes
    person = ActiveRecord::Base.connection.select_one('SELECT * FROM person WHERE user_name=' + username )
	
		if person.nil? 
      self.email = "guest@hih.com"
			update_user_role("guest")
		else
	    self.email = person["EmailAddress"]
 		end

		if person["type"].nil? then person_type =  "guest" else person_type =  person["type"] end
		update_user_role(person_type)		
  end

  def update_user_role (user_type)
		#If the role exists in the local database use it (staff/student/guest), otherwise turn to guest... 
		#Later throw exception, log, and set to guest... 
		if Role.find_or_initialize_by_name(user_type).persisted? then role =  Role.find_or_initialize_by_name(user_type) else role = Role.find_or_initialize_by_name("guest") end
		
 		#Does this role exist in the current table...
		if !self.roles.include?(role)
	    delete_standard_roles_from_user			
      self.roles << role 
		end
	end

	#Use this method to remove all staff/student/guest roles from a user
	def delete_standard_roles_from_user
		standard_roles = []
    ["staff", "student", "guest"].each {|r| standard_roles << find_or_initialize_by_name(r) } 		
		self.roles.delete_if {|role| standard_roles.include?(role) }
	end

end
