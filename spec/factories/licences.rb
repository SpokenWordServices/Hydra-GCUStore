# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :licence do
    name "MyString"
    description "MyText"
    link "MyString"
    download false
  end
end
