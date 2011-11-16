@show @structural_sets @local
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]

Scenario: ContentAccessTeam visits Show Page for Structural set
    Given I am logged in as "contentAccessTeam1@example.com" 
    And I am on the show document page for hull:3374
    Then I should see "Root set > Electronic Theses and Dissertations (ETD)"
		And I should see "Show set members"
    And I should see "Accounting"
    And I should see a link to "the edit document page for hull:3374"
