require 'mediashelf/active_fedora_helper'
class PermissionsController < ApplicationController
  include MediaShelf::ActiveFedoraHelper
  include Hydra::AssetsControllerHelper
  
  before_filter :require_solr
  before_filter :check_for_children, :only => [:update]

  # need to include this after the :require_solr/fedora before filters because of the before filter that the workflow provides.
  include Hydra::SubmissionWorkflow
  
  def index
		debugger
    @document_fedora=ActiveFedora::Base.load_instance(params[:asset_id])
    pid = params[:asset_id]
    dsid = "rightsMetadata"
    xml_content = @document_fedora.datastreams_in_memory[dsid].content
    ds = Hydra::RightsMetadata.from_xml(xml_content)
    ds.pid = pid
    ds.dsid = dsid
    @document_fedora.datastreams_in_memory[dsid] = ds
    
    respond_to do |format|
      format.html 
      format.inline { render :partial=>"permissions/index.html", :format=>"html" }
    end
  end
  
  def new
=begin
HYDRA-150
Removed from permissions/_new.html.erb
<% javascript_includes << ["jquery.form.js", {:plugin=>"hydra-head"}] %>
=end
    respond_to do |format|
      format.html 
      format.inline { render :partial=>"permissions/new.html" }
    end
  end
  
  def edit
    @document_fedora=ActiveFedora::Base.load_instance(params[:asset_id])
    pid = params[:asset_id]
    dsid = "rightsMetadata"
    xml_content = @document_fedora.datastreams_in_memory[dsid].content
    ds = Hydra::RightsMetadata.from_xml(xml_content)
    ds.pid = pid
    ds.dsid = dsid
    @document_fedora.datastreams_in_memory[dsid] = ds
    
    respond_to do |format|
      format.html 
      format.inline {render :action=>"edit", :layout=>false}
    end
  end
  
  # Create a new permissions entry
  # expects permission["actor_id"], permission["actor_type"] and permission["access_level"] as params. ie.   :permission=>{"actor_id"=>"_person_id_","actor_type"=>"person","access_level"=>"read"}
  def create
    #pid = params[:asset_id]
    pid = params[:asset_id]
    dsid = "rightsMetadata"
    # xml_content = Fedora::Repository.instance.fetch_custom(pid, "datastreams/#{dsid}/content")
    #@document_fedora=ActiveFedora::Base.load_instance(params[:asset_id])
    @document_fedora=ActiveFedora::Base.load_instance(params[:asset_id])
    xml_content = @document_fedora.datastreams[dsid].content
    ds = Hydra::RightsMetadata.new(@document_fedora.inner_object, dsid)
    Hydra::RightsMetadata.from_xml(xml_content, ds)

    @document_fedora.datastreams[dsid] = ds
    
    access_actor_type = params["permission"]["actor_type"]
    actor_id = params["permission"]["actor_id"]
    access_level = params["permission"]["access_level"]
  
    # update the datastream's values
    result = ds.permissions({access_actor_type => actor_id}, access_level)
      
    ds.serialize!
    ds.save
    
    # Re-index the object
    Solrizer::Fedora::Solrizer.new.solrize(pid)
    
    #flash[:notice] = "#{actor_id} has been granted #{access_level} permissions for #{params[:asset_id]}"
    flash[:notice] = "#{actor_id} has been granted #{access_level} permissions for #{params[:asset_id]}"
    
    respond_to do |format|
      #format.html { redirect_to :controller=>"permissions", :action=>"index" }
      format.html do 
        if params.has_key?(:add_permission)
          redirect_to :back
        else
          #redirect_to :controller=>"catalog", :action=>"edit", :id => params[:asset_id], :wf_step => next_step_in_workflow(:permissions)
          redirect_to( {:controller => "catalog", :action => "edit", :id => params[:asset_id]}.merge(params_for_next_step_in_wokflow) )
        end
        
      end
      format.inline { render :partial=>"permissions/edit_person_permissions", :locals=>{:person_id=>actor_id}}
    end

  end
  
  # Updates the permissions for all actors in a hash.  Can specify as many groups and persons as you want
  # ie. :permission => {"group"=>{"group1"=>"discover","group2"=>"edit"}, {"person"=>{"person1"=>"read"}}}
  def update

	  if params[:id].nil?  
      pid = params[:asset_id]
    else
      pid = params[:id]
    end
		
		if params[:datastream].nil?
			dsid = "rightsMetadata"
		else
			dsid = params[:datastream]
	  end

    af = ActiveFedora::Base.load_instance(pid)
    the_model = ActiveFedora::ContentModel.known_models_for( af ).first
    unless the_model.nil?
      af = the_model.load_instance(pid) 
    end
    
    if the_model == StructuralSet 
      af.update_set_permissions(params[:permission], dsid)  
    else
      af.update_object_permissions(params[:permission], "rightsMetadata")
    end        
    
    flash[:notice] = "The permissions have been updated."
    redirect_to :controller=>"catalog", :action=>"edit", :id => pid

  end


 private 

 #If the defaultObjectRights are being changed (structuralSet), then the permissions 
 #should only be updated if the set is empty...
  def check_for_children
    unless params[:datastream].nil?
      if params[:datastream] == "defaultObjectRights"
        if params[:id].nil?  
          pid = params[:asset_id]
        else
          pid = params[:id]
        end

        af = ActiveFedora::Base.load_instance(pid)
        the_model = ActiveFedora::ContentModel.known_models_for( af ).first
        unless the_model.nil?
          af = the_model.load_instance(pid) 
        end
    
        if the_model == StructuralSet 
          children = af.children_match_parent_default_object_rights
          children_dont_match =  children[:dont_match]
         
          if children_dont_match.count > 0
            id_list = ""

            list_of_ids = children[:dont_match].map {|child| child[:id]}     
            list_of_ids.each { |id| id_list << "<li>" + id + "</li>" }
            
            message = <<-EOS
              <p>The following objects do not match the original rights metadata for this set:</p>
              <ul>
               #{id_list}
              </ul>
              <p>If you intend to proceed you should print this page for your records.</p>          
            EOS

            flash[:notice] =  message.html_safe
    	      redirect_to :controller=>"catalog", :action=>"edit", :id => pid
          end
        end
    end
    end
  end   
end

