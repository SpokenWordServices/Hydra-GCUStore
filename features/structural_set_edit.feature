@edit @structural_sets 
Feature: ContentAccessTeam edit a Structural set
  In order to [goal]
  [stakeholder]
  wants [behaviour]

  Scenario: Visit Document Edit Structual set page
    Given I am logged in as "contentAccessTeam1@example.com" 
    And I am on the edit document page for hull:3374
    Then I should see an inline edit containing "Accounting"
		And I should see a "div" tag with a "id" attribute of "description-text"


  Scenario: Edit the permissions for a structural set that has non-matching children
    Given I am logged in as "contentAccessTeam1@example.com" 
    And I am on the edit document page for hull:4755
    Then I should see an inline edit containing "1st Level Test Set"
    When I select "Discover" from "Public"
    And I press "Save permissions"
    Then I should see "The following objects do not match the original rights metadata for this set"
    And I should see "hull:4756"   

 
 
