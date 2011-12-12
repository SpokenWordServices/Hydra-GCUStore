require 'hydra'

class GenericContent < ActiveFedora::Base
 
  include Hydra::ModelMethods
  include HullModelMethods
  include HullValidationMethods
	
 	#Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :label=>"Rights metadata", :type => Hydra::RightsMetadata 
 
  has_metadata :name => "descMetadata", :label=>"MODS metadata", :control_group=>"M", :type => ModsGenericContent
  
	has_metadata :name => "contentMetadata", :label=>"Content metadata", :control_group=>"M", :type => ContentMetadata

  has_metadata :name => "DC", :label=>"DC admin metadata", :type => ObjectDc

  has_datastream :name=>"content", :label=>"content", :type=>ActiveFedora::Datastream, :mimeType=>"application/pdf", :controlGroup=>'M'

  delegate :title, :to=>:descMetadata 
  delegate :coordinates, :to=>:descMetadata
  delegate :topic_tag, :to=>:descMetadata
  delegate :geographic_tag, :to=>:descMetadata
  delegate :temporal_tag, :to=>:descMetadata
  delegate :rights, :to=>:descMetadata
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
  
end
