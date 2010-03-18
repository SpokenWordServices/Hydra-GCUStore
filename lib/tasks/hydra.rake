# require File.expand_path(File.dirname(__FILE__) + '/hydra_jetty.rb')


namespace :hydra do
  task :fix_samples do
    Fedora::Repository.instance.find_objects('').each do |fo|
      doc = ActiveFedora::Base.load_instance(fo.pid)
      doc.add_relationship(:has_model, ActiveFedora::ContentModel.pid_from_ruby_class(SaltDocument))
      doc.save
    end
  end
end