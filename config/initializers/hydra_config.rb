# The following lines determine which user attributes your hydrangea app will use
# This configuration allows you to use the out of the box ActiveRecord associations between users and user_attributes
# It also allows you to specify your own user attributes
# The easiest way to override these methods would be to create your own module to include in User
# For example you could create a module for your local LDAP instance called MyLocalLDAPUserAttributes:
#   User.send(:include, MyLocalLDAPAttributes)
# As long as your module includes methods for full_name, affiliation, and photo the personalization_helper should function correctly
#
# NOTE: For your development environment, also specify the module in lib/user_attributes_loader.rb
User.send(:include, Hydra::GenericUserAttributes)

HULL_QUEUES = {
  "info:fedora/hull:3976" => :proto,
  "info:fedora/hull:732" => :qa
}
