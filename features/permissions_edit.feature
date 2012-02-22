@permissions
Feature: Edit Permissions
  As a user with edit permissions
  In order to edit who has which levels of access to a document
  I want to see and edit the object-level permissions for users and groups

  Scenario: Changing the defaultObjectRights of a structural set with children
    Given I am logged in as "contentAccessTeam1@example.com" 
    Given I am on the edit document page for hull:3374 
		Then I select "Discover" from "student_group_access"
		Then I select "Read & Download" from "staff_group_access"
		And I press "Save permissions"
    Then I should see "You cannot change the default object permissions: There is already content in this set"
   
 Scenario: Changing the defaultObjectRights of a structural set without children
    Given I am logged in as "contentAccessTeam1@example.com" 
    Given I am on the edit document page for hull:657 
		Then I select "Discover" from "student_group_access"
		Then I select "Read & Download" from "staff_group_access"
		And I press "Save permissions"
    Then I should see "The permissions have been updated."
  
  #Scenario: Viewing individual permissions
  #  Given I am logged in as "archivist1@example.com" 
  #  Given I am on the edit document page for hydrangea:fixture_mods_article1 
  #  Then the "Archivist" field should contain "edit"
  #  And the "researcher1" field should contain "edit"

  Scenario: Viewing individual permissions
    Given I am logged in as "contentAccessTeam1@example.com" 
    Given I am on the edit document page for hull:3375 
    Then the "Archivist" field should contain "none"
    And the "Public" field should contain "read"
    And the "Researcher" field should contain "none"
