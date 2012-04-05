module StructuralSetChildren
  module ClassMethods
    
    @@children = []

    def children pid 
      @@children = []
      create_set_members_array pid     
      @@children.flatten!       
    end

    def create_set_members_array pid          
      unless pid.nil? 
        hits = retrieve_set_members escape_colon(pid)
        if hits.length > 0 
          @@children << hits 
          hits.each do |hit|
            create_set_members_array hit["id"] if hit["has_model_s"].to_s == "info:fedora/hull-cModel:structuralSet"
          end
        end
      end
    end
    

    def retrieve_set_members pid
      fields = "is_member_of_s:info\\:fedora/" + pid
      options = {:field_list=>["id", "id_t", "title_t", "is_member_of_s", "has_model_s"], :rows=>10000, :sort=>[{"system_create_dt"=>:ascending}]}
      ActiveFedora::SolrService.instance.conn.query(fields,options).hits
    end

    def escape_colon str
      str.gsub(/[:]/,  '\\:') 
    end

 
  end 

  def self.included(base)
     base.extend(ClassMethods)
  end


 def initialize(attrs=nil)
    super(attrs)
    after_create() if new_object?
  end

end

