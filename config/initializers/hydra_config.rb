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
  "info:fedora/hull:protoQueue" => :proto,
  "info:fedora/hull:QAQueue" => :qa
}
GROUP_PERMISSIONS = {
	"create_resources" => ["contentAccessTeam"]
}


# The following code represents hull-specific overrides to ActiveFedora.  In some cases,
# the overrides can be propogated up to ActiveFedora itself
module ActiveFedora
  class ContentModel
    def self.pid_from_ruby_class(klass,attrs={})
      class_name = klass.name.gsub(/(::)/, '_')
      sanitized_class_name = class_name[0,1].downcase + class_name[1..-1]
      unless klass.respond_to? :pid_suffix
        pid_suffix = attrs.has_key?(:pid_suffix) ? attrs[:pid_suffix] : CMODEL_PID_SUFFIX
      else
        pid_suffix = klass.pid_suffix
      end
      unless klass.respond_to? :pid_namespace
        namespace = attrs.has_key?(:namespace) ? attrs[:namespace] : CMODEL_NAMESPACE   
      else
        namespace = klass.pid_namespace
      end
      return "#{namespace}:#{sanitized_class_name}#{pid_suffix}" 
  
    end
  end
end
