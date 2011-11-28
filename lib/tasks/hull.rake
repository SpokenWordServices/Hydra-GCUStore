# require File.expand_path(File.dirname(__FILE__) + '/hydra_jetty.rb')
require "solrizer-fedora"
require 'jettywrapper'
require 'win32/process' if RUBY_PLATFORM =~ /mswin32|mingw|cygwin/


namespace :hull do
  
  namespace :default_fixtures do

    desc "Load default hull fixtures via hydra"
    task :load => [:load_dependencies, :ingest] do

      # fixture_files.each_with_index do |fixture,index|
      #   ENV["pid"] = nil
      #   ENV["fixture"] = fixture
      #   Rake::Task["hydra:import_fixture"].reenable
      #   Rake::Task["hydra:import_fixture"].invoke
      # end
      # fixture_files.each_with_index do |fixture,index|
      #   ENV["PID"] = pid_from_path(fixture) #fixture.split("/")[-1].gsub(".xml","").gsub("_",":")
      #   Rake::Task["solrizer:fedora:solrize"].reenable
      #   Rake::Task["solrizer:fedora:solrize"].invoke
      # end
    end

    desc "Load the default fixtures via fedora's ingest"
    task :ingest => :environment do
        puts "opening files"
        fixture_files.each_with_index do |fixture,index|
          pid = pid_from_path(fixture)
          body = ''
          begin
            ActiveFedora::FixtureLoader.import_to_fedora(fixture)
            ActiveFedora::FixtureLoader.index(pid)
          rescue
            #typically an "object exists" error
          end
          puts " Ingested #{pid}"
        end
    end

    desc "Load the dependencies (sDeps,sDefs,etc.)"
    task :load_dependencies => :environment do
        puts "loading dependencies"
        dependencies.each do |dependency|
          pid = pid_from_path(dependency)
          puts "Loading #{dependency}..."
          begin
            ActiveFedora::FixtureLoader.import_to_fedora(dependency)
            ActiveFedora::FixtureLoader.index(pid)
          rescue
            #typically an "object exists" error
          end
          puts "Loaded #{pid}"
        end
    end

    desc "Remove the dependencies (sDeps,sDefs,etc.)"
    task :delete_dependencies do
      dependencies.each_with_index do |dependency,index|
        ENV['pid'] = pid_from_path(dependency)
        puts "removing #{dependency}"
        Rake::Task["hydra:delete"].reenable
        Rake::Task["hydra:delete"].invoke
      end
    end

    desc "Remove default hull fixtures"
    task :delete do
      fixture_files.each_with_index do |fixture,index|
        ENV["pid"] = pid_from_path(fixture)
        puts "deleting #{fixture}"
        puts "#{ENV["pid"]}"
        Rake::Task["hydra:delete"].reenable
        Rake::Task["hydra:delete"].invoke
      end
    end

    desc "Refresh default hull fixtures"
    task :refresh do
      Rake::Task["hull:default_fixtures:delete"].invoke
      Rake::Task["hull:default_fixtures:load"].invoke
    end
  end

  desc "Hudson/Jenkins CI build"
  task :hudson do
    if (ENV['RAILS_ENV'] == "test")
      workspace_dir = ENV['WORKSPACE'] # workspace should be set by Hudson
      project_dir = workspace_dir ? workspace_dir : ENV['PWD']
      #Rake::Task["db:test:clone_structure"].invoke
      Rake::Task["hydra:jetty:config:all"].invoke
      jetty_params = {
        :jetty_home => "#{project_dir}/jetty",
        :quiet => false,
        :jetty_port => 8983,
        :solr_home => "#{project_dir}/jetty/solr",
        :fedora_home => "#{project_dir}/jetty/fedora/default",
        :startup_wait => 30
      }
      jetty_params = Jettywrapper.load_config.merge(jetty_params)

      #Rake::Task["db:drop"].invoke
      Rake::Task["db:migrate"].invoke
      #Rake::Task["db:migrate:plugins"].invoke
      error = Jettywrapper.wrap(jetty_params) do
        puts "Refreshing fixtures in development fedora/solr (need these for the disseminators to work)"
        puts %x[rake hull:default_fixtures:load RAILS_ENV=development]
        puts "Refreshing fixtures in test fedora/solr"
        Rake::Task["hull:default_fixtures:load"].invoke
        # Rake::Task["spec_without_db"].invoke
        Rake::Task["spec"].invoke
        Rake::Task["cucumber"].invoke
      end
      raise "test failures: #{error}" if error
    else
      system("rake hull:hudson RAILS_ENV=test")
    end
  end

end

def fixture_files
  Dir.glob(File.join("#{Rails.root}","spec","fixtures", "hull", Rails.env, "*.xml")) +
  Dir.glob(File.join("#{Rails.root}","spec","fixtures","hull","*.xml"))
end

def dependencies
  Dir.glob(File.join("#{Rails.root}","spec","fixtures","hull", Rails.env, "dependencies","*.xml")) +
  Dir.glob(File.join("#{Rails.root}","spec","fixtures","hull","dependencies","*.xml"))
end

def pid_from_path(path)
  path.split("/")[-1].gsub(/(\.foxml)?\.xml/,"").sub("_",":")
end
