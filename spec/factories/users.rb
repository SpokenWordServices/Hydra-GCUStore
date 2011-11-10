# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cat, :class=>User do
    email 'contentaccessteam1@example.com'
    password 'foobar'
  end
  factory :student1, :class=>User do
    email 'student1@example.com'
    password 'foobar'
  end
end
