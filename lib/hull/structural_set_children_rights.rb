module StructuralSetChildrenRights


  def update_set_children_rights permission_params

    children = children_match_parent_default_object_rights

    unless children.nil?
      matched_children = children[:match]

      unless matched_children.nil?
        matched_children.each do |child|
          id = child[:id]
          has_model_s = child[:has_model_s]

          if has_model_s  == "info:fedora/hull-cModel:structuralSet"
            ds_id = "defaultObjectRights"
          else
            ds_id = "rightsMetadata"
          end

          obj = child_object_instance id

          ds = Hydra::RightsMetadata.new(obj.inner_object, ds_id)
         
          result = ds.update_permissions(permission_params)
          ds.serialize!
          ds.save

          # Re-index the object
          Solrizer::Fedora::Solrizer.new.solrize(id)
        end
      end
    end
  end


  def children_match_parent_default_object_rights

    match = []
    dont_match = []

    children = StructuralSet.children self.pid 

    rights_ds = Hydra::RightsMetadata.new(self.inner_object, "defaultObjectRights")

    unless children.nil?
      children.each do |child|       
        child_instance = child_object_instance child["id"]

        unless in_queue? child_instance 
          if child["has_model_s"].to_s == "info:fedora/hull-cModel:structuralSet"
            ds_id = "defaultObjectRights"
          else
            ds_id = "rightsMetadata"
          end
              
          object_match = compare_object_with_rights({:object=>child_instance, :ds_id=>ds_id } , rights_ds)
           
          if object_match
            match << {:id => child["id"], :has_model_s => child["has_model_s"].to_s }
          else
            dont_match << {:id => child["id"], :has_model_s => child["has_model_s"].to_s }
          end
        end     
      end
    end

   return {:match => match, :dont_match => dont_match}

  end


  def child_object_instance pid
    af = ActiveFedora::Base.load_instance(pid)
    the_model = ActiveFedora::ContentModel.known_models_for( af ).first
    unless the_model.nil?
      af = the_model.load_instance(pid) 
    end
  end

  def in_queue? obj
    !obj.queue_membership.empty?       
  end 


  def compare_object_with_rights(object, rights)
    
    instance = object[:object]
    ds_id  = object[:ds_id]

    ds = Hydra::RightsMetadata.new(instance.inner_object, ds_id)  
    ds.groups == rights.groups

   end 
 

end


