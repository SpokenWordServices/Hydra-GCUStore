require 'spec_helper'

describe StructuralSet do
  it "should return a tree" do
    root_node = StructuralSet.tree
    root_node.print_tree


    puts "Attempting to get options for select"
    options = root_node.options_for_nested_select

    options.each {|v| puts "#{v[0]} = #{v[1]}" }
  end
  
  it "should do provide a set of options for a fedora_select nested select" do
    options = StructuralSet.tree.options_for_nested_select
    options.each {|v| puts "#{v[0]} = #{v[1]}" }
  end

  describe "a saved instance" do
    before do
      @instance = StructuralSet.new
      @instance.save
      @instance = StructuralSet.find(@instance.pid)
    end
    it "should have defaultObjectRights datastream" do
      @instance.defaultObjectRights.content.should be_equivalent_to '
<rightsMetadata xmlns="http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1">
  <copyright>
    <human></human>
    <machine></machine>
  </copyright>
  <access type="discover">
    <human></human>
    <machine>
      <group>contentAccessTeam</group>
    </machine>
  </access>
  <access type="read">
    <human></human>
    <machine>
      <group>contentAccessTeam</group>
    </machine>
  </access>
  <access type="edit">
    <human></human>
    <machine>
      <group>contentAccessTeam</group>
    </machine>
  </access>
  <use>
    <human></human>
    <machine></machine>
  </use>
  <embargo>
    <human></human>
    <machine></machine>
  </embargo>
</rightsMetadata>
'
    end
    it "should be governedBy " do
      @instance.is_governed_by.should == ["info:fedora/hull-apo:structuralSet"]
    end

    it "should index only the rightsMetadata (not defaultObjectRights)" do
      # A new structural set should always inherit the defaultObjectRights of
      # its parent and have an isGovernedBy to hull-apo:structuralSet.  If it is
      # a top level set it will inherit its defaultObjectRights from
      # hull:rootSet
      # 
      # The rightsMetadata for *any* structural set is 'contentAccessTeam' only
      # which is in the apo and what all the 'isGovernedBy' relationships
      # ensure. - RightsMetadata always comes from an APO.
      @instance.defaultObjectRights.edit_access.machine.group.should == ["contentAccessTeam"]
      ## @instance.rightsMetadata should be copied from its governing structural set's defaultObjectRights
      @instance.rightsMetadata.edit_access.machine.group.should == ['contentAccessTeam']
      @instance.to_solr["rightsMetadata_0_access_0_machine_0_group_t"].should == ['contentAccessTeam']
    end

    after do
      @instance.delete
    end

  end

  describe "inheritance" do
    before do
      @instance = StructuralSet.new
      @instance.save
      @instance = StructuralSet.find(@instance.pid)
      @parent = StructuralSet.new
      @parent.defaultObjectRights.update_indexed_attributes([:edit_access]=> 'baz')
      @parent.save
    end
    it "should inherit the rightsMetadata and defaultObjectRights from the parents defaultObjectRights when the parent structuralSet is updated" do
      @instance.apply_governed_by(@parent)
      @instance.rightsMetadata.edit_access.should == ['baz']
      @instance.defaultObjectRights.edit_access.should == ['baz']
    end
    after do
      @instance.delete
      @parent.delete
    end
  end


  describe "structural set recursive permissions" do
    before do
      permission_params = {"group"=>{"public"=>"read", "baz"=>"edit", "contentAccessTeam"=>"edit"}}
      alt_permission_params = {"group"=>{"staff"=>"read", "baz"=>"edit", "contentAccessTeam"=>"edit"}} 

      @parent = StructuralSet.new
      @parent.save
      @parent.defaultObjectRights.update_permissions(permission_params)
      @parent.save

      @first_child = StructuralSet.new 
      @first_child.save      
      @first_child.defaultObjectRights.update_permissions(permission_params)
      @first_child.apply_set_membership(["info:fedora/" + @parent.pid])
      @first_child.save

      @second_child = StructuralSet.new 
      @second_child.save      
      @second_child.defaultObjectRights.update_permissions(alt_permission_params)
      @second_child.apply_set_membership(["info:fedora/" + @parent.pid])
      @second_child.save

      @first_child_content_object = ExamPaper.new
      @first_child_content_object.save
      @first_child_content_object.rightsMetadata.update_permissions(permission_params)
      @first_child_content_object.remove_relationship :is_member_of, HULL_QUEUES.invert[:proto]
      @first_child_content_object.apply_set_membership(["info:fedora/" + @first_child.pid])
      @first_child_content_object.apply_governed_by("info:fedora/" +  @first_child.pid)
      @first_child_content_object.save

      @second_child_content_object = ExamPaper.new
      @second_child_content_object.save
      @second_child_content_object.rightsMetadata.update_permissions(alt_permission_params)
      @second_child_content_object.remove_relationship :is_member_of, HULL_QUEUES.invert[:proto]
      @second_child_content_object.apply_set_membership(["info:fedora/" + @second_child.pid])
      @second_child_content_object.apply_governed_by("info:fedora/" + @second_child.pid)
      @second_child_content_object.save


    end
    it "should return a list of all children" do
      children = StructuralSet.children @parent.pid 
      children.should == [{"has_model_s"=>["info:fedora/hull-cModel:structuralSet"], "id"=> @first_child.pid, "id_t"=>[ @first_child.pid],
                           "is_member_of_s"=>["info:fedora/" + @parent.pid]}, {"has_model_s"=>["info:fedora/hull-cModel:structuralSet"], "id"=>@second_child.pid,
                           "id_t"=> [@second_child.pid], "is_member_of_s"=>["info:fedora/" + @parent.pid]}, {"has_model_s"=>["info:fedora/hull-cModel:examPaper"],
                           "id"=>@first_child_content_object.pid, "id_t"=>[@first_child_content_object.pid], "is_member_of_s"=>["info:fedora/" + @first_child.pid ]},
                           {"has_model_s"=>["info:fedora/hull-cModel:examPaper"], "id"=>@second_child_content_object.pid, "id_t"=>[@second_child_content_object.pid],
                           "is_member_of_s"=>["info:fedora/" + @second_child.pid]}]
    end
    it "should return correctly the list of matching and non-matching children" do
        @parent.children_match_parent_default_object_rights.should == {:dont_match=>[{:has_model_s=>"info:fedora/hull-cModel:structuralSet", :id=> @second_child.pid},
                     {:has_model_s=>"info:fedora/hull-cModel:examPaper", :id=> @second_child_content_object.pid}], 
                        :match=>[{:has_model_s=>"info:fedora/hull-cModel:structuralSet", :id=>@first_child.pid},
                         {:has_model_s=>"info:fedora/hull-cModel:examPaper", :id=>@first_child_content_object.pid}]}

    end
    it "should update the permissions of matching children only" do
      new_permission_params = {"group"=>{"contentAccessTeam"=>"none", "public"=>"none", "baz"=>"edit"}}
  
      @parent.update_set_permissions(new_permission_params, "defaultObjectRights") 

      #Reload the children from fedora...
      @first_child = StructuralSet.load_instance(@first_child.pid)
      @first_child_content_object = ExamPaper.load_instance(@first_child_content_object.pid)
      @second_child = StructuralSet.load_instance(@second_child.pid)
      @second_child_content_object = ExamPaper.load_instance(@second_child_content_object.pid)
     
      #Matching child should have been updated...
      @parent.defaultObjectRights.groups.should == {"baz"=>"edit"}
      @first_child.defaultObjectRights.groups.should == {"baz"=>"edit"}
      @first_child_content_object.rightsMetadata.groups.should == {"baz"=>"edit"}

      #Non-matching children don't update...
      @second_child.defaultObjectRights.groups.should == {"staff"=>"read", "baz"=>"edit", "contentAccessTeam"=>"edit"}
      @second_child_content_object.rightsMetadata.groups.should == {"staff"=>"read", "baz"=>"edit", "contentAccessTeam"=>"edit"} 
    end

    after do
      @parent.delete
      @first_child.delete
      @first_child_content_object.delete
      @second_child.delete
      @second_child_content_object.delete
    end
  end

end
