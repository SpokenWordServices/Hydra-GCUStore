require_dependency 'vendor/plugins/hydra_repository/app/controllers/permissions_controller.rb'

class PermissionsController

 # Updates the permissions for all actors in a hash.  Can specify as many groups and persons as you want
  # ie. :permission => {"group"=>{"group1"=>"discover","group2"=>"edit"}, {"person"=>{"person1"=>"read"}}}
  def update
    pid = params[:asset_id]
    dsid = "rightsMetadata"
    # xml_content = Fedora::Repository.instance.fetch_custom(pid, "datastreams/#{dsid}/content")
    @document_fedora=ActiveFedora::Base.load_instance(params[:asset_id])
    xml_content = @document_fedora.datastreams_in_memory[dsid].content
    ds = Hydra::RightsMetadata.from_xml(xml_content)
    ds.pid = pid
    ds.dsid = dsid
    @document_fedora.datastreams_in_memory[dsid] = ds
    
    # update the datastream's values
    result = ds.update_permissions(params[:permission])
    
    # Replace the object's datastream with the new updated ds
    # !! Careful when re-working this.  If you init the object, replace the datastream, and call object.save, the datastream might get indexed twice!
    # FUTURE: ActiveFedora::Base will support this soon:
    # ActiveFedora::Base.replace_datastream("changeme:25","rightsMetadata", ds).
    # base_object.replace_datastream("rightsMetadata", ds)
    ds.pid = pid
    ds.dsid = dsid
    ds.save
    
    # Re-index the object
    Solrizer::Fedora::Solrizer.new.solrize(pid)
    
    # This should be replaced ...
    if params[:permission].has_key?(:group)
      access_actor_type = "group"
    else
      access_actor_type = "person"
    end
    actor_id = params["permission"][access_actor_type].first[0]
 
	redirect_to( url_for(:controller=>"catalog", :action=>"edit", :id=>params[:asset_id] ) )    
   # render :partial=>"permissions/edit_person_permissions", :locals=>{:person_id=>actor_id}
  end


end
