@edit @datasets
Feature: Edit a Dataset
  In order to manage a dataset
  As a researcher
  I want to see & edit a dataset's values


  Scenario: Visit Dataset Edit Page
   Given I am logged in as "archivist1" 
    And I am on the edit document page for hydrangea:fixture_mods_dataset1 
#    Then I should see "Fixture Marine Biology Dataset" within "h1.document_heading"
    And I should see an inline edit containing "Fixture Marine Biology Dataset"
    
 Scenario: Viewing browse/edit buttons
    Given I am logged in as "archivist1" 
    And I am on the edit document page for hydrangea:fixture_mods_article1
    Then I should see a "span" tag with a "class" attribute of "edit-browse"


