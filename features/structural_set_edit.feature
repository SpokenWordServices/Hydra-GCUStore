@edit @structural_sets 
Feature: ContentAccessTeam edit a Structural set
  In order to [goal]
  [stakeholder]
  wants [behaviour]

  Scenario: Visit Document Edit Structual set page
    Given I am logged in as "contentAccessTeam1" 
    And I am on the edit document page for hull:3374
    Then I should see an inline edit containing "Accounting"
		And I should see a "div" tag with a "id" attribute of "description-text"

 
 
