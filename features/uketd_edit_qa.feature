@edit @articles
Feature: QA edit a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
 
  @wip
  Scenario: Visit Document Edit QA Page
    Given I am logged in as "contentAccessTeam1" 
    And I am on the edit document page for hull:3112
    And I should see an inline edit containing "Accounting regulation in Egypt in relation to western influence"
	Then I should see "Additional metadata"

  Scenario: Viewing browse/edit buttons
    Given I am logged in as "archivist1" 
    And I am on the edit document page for hydrangea:fixture_mods_article1
    Then I should see a "span" tag with a "class" attribute of "edit-browse"
    
