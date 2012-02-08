# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cat, :class=>User do
   # username 'contentaccessteam1'
    email 'contentaccessteam1@example.com'
  end
  factory :student1, :class=>User do
   # username 'student1'
    email 'student1@example.com'
  end
end
