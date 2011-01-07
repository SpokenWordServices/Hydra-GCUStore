# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require 'spec/rake/spectask'

desc "Run the rspec examples"
task :spec => ["db:test:clone_structure", "spec_without_db"] do
end

desc "Run the rspec examples without re-creating the test database first"
Spec::Rake::SpecTask.new('spec_without_db') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end
