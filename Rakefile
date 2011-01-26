# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require 'spec/rake/spectask'

desc "Set the RAILS_ENV to test"
task :set_test do
  ENV['RAILS_ENV'] = "test"
end

desc "Run the hydrangea rspec examples"
  task :spec => ["set_test", "db:test:clone_structure", "hydra:default_fixtures:refresh", "spec_without_db"] do
end

desc "Run the rspec examples without re-creating the test database first"
Spec::Rake::SpecTask.new('spec_without_db') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = %w{--exclude spec\/*,gems\/*,ruby\/* --aggregate coverage.data}
end

desc "Run all hydrangea tests"
  task :alltests => ["set_test", "db:test:clone_structure", "hydra:default_fixtures:refresh", "spec_without_db", "cucumber"] do
end