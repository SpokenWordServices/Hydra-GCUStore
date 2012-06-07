# Basic Video Object

require 'hydra'

class GenericVideo < ActiveFedora::Base

  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods
	include ActiveFedora::ServiceDefinitions
	include CommonMetadataSdef


  # Datastreams

	#RELS-EXT
  self.ds_specs = {'RELS-EXT'=> {:type=> ActiveFedora::RelsExtDatastream, :label=>"Fedora Object-to-Object Relationship Metadata", :control_group=>'X', :block=>nil}}
	
 	#Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :label=>"Rights metadata", :type => RightsMetadata 
 
  #Uses Hydra descMetadata to hold MODS
  has_metadata :name => "descMetadata", :label=>"MODS metadata", :control_group=>"M", :type => ModsGenericContent do |m|
    m.genre ="Video"
  end
  
  # Might use this later - enables download links 
	has_metadata :name => "contentMetadata", :label=>"Content metadata", :control_group=>"M", :type => ContentMetadata

  # Basic DC
  has_metadata :name => "DC", :label=>"DC admin metadata", :type => ObjectDc

  # A place to put extra metadata values
  has_metadata :name => "properties", :label=>"Workflow properties", :type => ActiveFedora::MetadataDatastream do |m|
    m.field 'collection', :string
    m.field 'depositorEmail', :string  
    m.field 'depositor', :string
  end

  # For ease of reference

  delegate :title, :to=>:descMetadata 
  delegate :sub_title, :to=>:descMetadata 
  delegate :coordinates, :to=>:descMetadata
  delegate :topic_tag, :to=>:descMetadata
  delegate :geographic_tag, :to=>:descMetadata
  delegate :temporal_tag, :to=>:descMetadata
  delegate :rights, :to=>:descMetadata
  delegate :rights_label, :to=>:descMetadata
  delegate :rights_url, :to=>:descMetadata
  delegate :date_valid, :to=>:descMetadata
  delegate :description, :to=>:descMetadata
  delegate :related_item, :to=>:descMetadata
  delegate :extent, :to=>:descMetadata
  delegate :see_also, :to=>:descMetadata
  delegate :publisher, :to=>:descMetadata
  delegate :lang_text, :to=>:descMetadata
  delegate :lang_code, :to=>:descMetadata
  delegate :digital_origin, :to=>:descMetadata
  delegate :type_of_resource, :to=>:descMetadata

  # Not sure where this is used 

  def person=(attr)
    attr.each do |key, value|
      p = descMetadata.person(key.to_i)
      p.namePart = value['namePart']
      p.role.text = value['role']['text']
    end
  end

  # Supply person roles specific to audio objects to be used when editing mods

    def self.person_relator_terms
      {"hst" => "Host",
       "ctb" => "Contributor",
       "col" => "Collector",
       "cre" => "Creator",
       }
    end

  # Validations  - leave these out for the moment for simplicity 
=begin

  has_validation :validate_parameters do
    if @pending_attributes.fetch("descMetadata",nil)
			date_valid = @pending_attributes["descMetadata"][[:date_valid]]["0"] 
      if date_valid.present?
        begin
          Hull::Iso8601.parse(date_valid) 
        rescue ArgumentError
    			errors << "descMetadata error: invalid date"
        end
      end
		end		
    is_valid?
  end


	has_workflow_validation :qa do
    errors << "#{pid} is already in qa queue" if queue_membership.include? :qa
    validates_presence_of "descMetadata",[:title]
    validates_presence_of("descMetadata",[:name,:namePart])
    validates_presence_of("descMetadata",[:subject,:topic])
    is_valid?
  end

 has_workflow_validation :publish do
    validates_presence_of "descMetadata",[:title]
    validates_presence_of("descMetadata",[:name,:namePart])
    validates_presence_of("descMetadata",[:subject,:topic])
    is_valid?
  end

  has_workflow_validation :deleted do
    validates_presence_of ("descMetadata",[:admin_note])
    is_valid?
  end

  has_workflow_validation :hidden do
    validates_presence_of ("descMetadata",[:admin_note])
    is_valid?
  end
=end

  # Set Genre

  def genre=(val)
    g = Genre.find(val)
    descMetadata.genre = g.name
    # Richard Green said use the form field for type_of_resource on 2011-12-5  - jcoyne
    #descMetadata.type_of_resource = g.type
    add_relationship :has_model, "info:fedora/#{g.c_model}"
  end

  def genre
    descMetadata.genre
  end

  def person=(attr)
    attr.each do |key, value|
      p = descMetadata.person(key.to_i)
      p.namePart = value['namePart']
      p.role.text = value['role']['text']
    end
  end

  # Overridden so that we can store a cmodel and "complex Object"
  def assert_content_model
    g = Genre.find(descMetadata.genre.first)
    add_relationship(:has_model, "info:fedora/#{g.c_model}")
    add_relationship(:has_model, "info:fedora/hydra-cModel:compoundContent")
    add_relationship(:has_model, "info:fedora/hydra-cModel:commonMetadata")
  end

  def generate_dsid(prefix="DS")
    keys = datastreams.keys
    return prefix unless keys.include?(prefix)
    matches = keys.map {|d| data = /^#{prefix}(\d+)$/.match(d); data && data[1].to_i}.compact
    val = matches.empty? ? 2 : matches.max + 1
    sprintf("%s%02i", prefix,val)
  end

#	def apply_specific_base_metadata
#		#Applying the following metadata after the Object is created
#   	type_of_resource = "text"		
#		dc_ds = self.dc
#		desc_ds = self.descMetadata
#
#		dc_ds.update_indexed_attributes([:dc_title]=>self.get_values_from_datastream("descMetadata", [:title], {}).to_s) unless dc_ds.nil?
#
#		#Set type_of_resource based upon genre
#		genre = self.get_values_from_datastream("descMetadata", [:genre], {}).to_s
#		type_of_resource =  Genre.find(genre).type if Genre.find(genre).type.class == String
#		desc_ds.update_indexed_attributes([:type_of_resource]=> type_of_resource)
#	end
  

end
