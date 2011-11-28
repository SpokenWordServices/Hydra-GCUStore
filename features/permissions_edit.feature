@permissions
Feature: Edit Permissions
  As a user with edit permissions
  In order to edit who has which levels of access to a document
  I want to see and edit the object-level permissions for users and groups

  
  #Scenario: Viewing individual permissions
  #  Given I am logged in as "archivist1@example.com" 
  #  Given I am on the edit document page for hydrangea:fixture_mods_article1 
  #  Then the "Archivist" field should contain "edit"
  #  And the "researcher1" field should contain "edit"

  Scenario: Viewing individual permissions
    Given I am logged in as "contentAccessTeam1@example.com" 
    Given I am on the edit document page for hull:3375 
    Then the "Archivist" field should contain "none"
    And the "Public" field should contain "none"
    And the "Researcher" field should contain "none"
