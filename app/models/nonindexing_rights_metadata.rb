class NonindexingRightsMetadata < Hydra::RightsMetadata
  #TODO it would be nice to inherit this from Hydra::RightsMetadata
  set_terminology do |t|
    t.root(:path=>"rightsMetadata", :xmlns=>"http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1", :schema=>"http://github.com/projecthydra/schemas/tree/v1/rightsMetadata.xsd") 
    t.copyright {
      t.machine
      t.human_readable(:path=>"human")
    }
    t.access {
      t.human_readable(:path=>"human")
      t.machine {
        t.group
        t.person
      }
      t.person(:proxy=>[:machine, :person])
      t.group(:proxy=>[:machine, :group])
      # accessor :access_person, :term=>[:access, :machine, :person]
    }
    t.discover_access(:ref=>[:access], :attributes=>{:type=>"discover"})
    t.read_access(:ref=>[:access], :attributes=>{:type=>"read"})
    t.edit_access(:ref=>[:access], :attributes=>{:type=>"edit"})
    # A bug in OM prevnts us from declaring proxy terms at the root of a Terminology
    # t.access_person(:proxy=>[:access,:machine,:person])
    # t.access_group(:proxy=>[:access,:machine,:group])
    
    t.embargo {
      t.human_readable(:path=>"human")
      t.machine{
        t.date(:type =>"release")
      }
      t.embargo_release_date(:proxy => [:machine, :date])
    }    
  end

  def to_solr(obj)
    obj
  end

end
