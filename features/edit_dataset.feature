@edit, @dataset
Feature: Edit a Dataset
  In order to manage a dataset
  As a researcher
  I want to see & edit a dataset's values
  
  Scenario: Researcher Visits Dataset Edit Page
    Given I am logged in as "researcher1" 
    And I am on the edit document page for hydrangea:fixture_mods_dataset1
    Then the "methodology" field should contain "Observed deep below the sea aboard the Belafonte."
    Then the "location" field should contain "(31.95216223802497,-25.3125)"