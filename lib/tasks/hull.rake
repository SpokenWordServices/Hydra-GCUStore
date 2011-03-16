# require File.expand_path(File.dirname(__FILE__) + '/hydra_jetty.rb')
require "solrizer-fedora"
require 'win32/process' if RUBY_PLATFORM =~ /mswin32|mingw|cygwin/


namespace :hull do
  
  namespace :default_fixtures do

    desc "Load default hull fixtures via hydra"
    task :load do

      fixture_files.each_with_index do |fixture,index|
        ENV["pid"] = nil
        ENV["fixture"] = fixture
        Rake::Task["hydra:import_fixture"].invoke if index == 0
        Rake::Task["hydra:import_fixture"].execute if index > 0
      end
      fixture_files.each_with_index do |fixture,index|
        ENV["PID"] = pid_from_path(fixture) #fixture.split("/")[-1].gsub(".xml","").gsub("_",":")
        Rake::Task["solrizer:fedora:solrize"].invoke if index == 0
        Rake::Task["solrizer:fedora:solrize"].execute if index > 0
      end
    end

    desc "Load the default fixtures via fedora's ingest"
    task :ingest => :environment do
        puts "opening files"
        fixture_files.each_with_index do |fixture,index|
          pid = pid_from_path(fixture)
          fixture_file = File.open(fixture,"r")
          puts "Ingesting #{fixture} via REST API..."
          r = Fedora::Repository.instance.ingest(fixture_file,pid)
          puts " Ingested #{r.body}"
        end
    end

    desc "Load the dependencies (sDeps,sDefs,etc.)"
    task :load_dependencies => :environment do
        puts "loading dependencies"
        dependencies.each do |dependency|
          pid = pid_from_path(dependency)
          dependency_file = File.open(dependency,"r")
          puts "Loading #{dependency}..."
          r = Fedora::Repository.instance.ingest(dependency_file,pid)
          puts "Loaded #{r.body}"
        end
    end

    desc "Remove the dependencies (sDeps,sDefs,etc.)"
    task :delete_dependencies do
      dependencies.each_with_index do |dependency,index|
        ENV['pid'] = pid_from_path(dependency)
        puts "removing #{dependency}"
        Rake::Task["hydra:delete"].invoke if index == 0
        Rake::Task["hydra:delete"].execute if index > 0
      end
    end

    desc "Remove default hull fixtures"
    task :delete do
      fixture_files.each_with_index do |fixture,index|
        ENV["pid"] = pid_from_path(fixture)
        puts "deleting #{fixture}"
        puts "#{ENV["pid"]}"
        Rake::Task["hydra:delete"].invoke if index == 0
        Rake::Task["hydra:delete"].execute if index > 0
      end
    end

    desc "Refresh default hull fixtures"
    task :refresh do
      Rake::Task["hull:default_fixtures:delete"].invoke
      Rake::Task["hull:default_fixtures:load"].invoke
    end
  end

end

def fixture_files
  Dir.glob(File.join("#{Rails.root}","spec","fixtures","hull","*.xml"))
end

def dependencies
  Dir.glob(File.join("#{Rails.root}","spec","fixtures","hull","dependencies","*.xml"))
end

def pid_from_path(path)
  path.split("/")[-1].gsub(".xml","").gsub("_",":")
end
