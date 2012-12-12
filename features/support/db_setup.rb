Before do

  DatabaseCleaner.clean

  Factory(:person,:user_name=>'staff1', :userType => 'staff', :emailAddress => 'staff1@example.com')
  Factory(:person,:user_name=> 'student1', :userType => 'student', :emailAddress => 'student1@example.com')
  Factory(:person,:user_name=> 'cat1', :userType => 'contentAccessTeam', :emailAddress => 'contentaccessteam1@example.com')
  Factory(:person,:user_name=>  'cs1', :userType => 'committeeSection', :emailAddress => 'committeesection1@example.com')

  Factory(:role, :name => "contentAccessTeam")
  Factory(:role, :name=> "staff")
  Factory(:role, :name=>"student")
  Factory(:role, :name=>"committeeSection")
  Factory(:role, :name=>"guest")

  Factory(:licence, :name=>'Spoken Word End-User Licence', :link => 'http://catalogue.spokenword.ac.uk/spoken-word-end-user-licence-agreement.html', :description => 'This resource is downloadable under the Spoken Word End-User Licence. Please read and understand the licence before downloading.', :download => true)

end

