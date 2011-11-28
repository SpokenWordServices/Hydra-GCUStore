@edit @articles
Feature: QA edit a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
 
  Scenario: Visit Document Edit QA Page
    Given I am logged in as "contentAccessTeam1@example.com" 
    And I am on the edit document page for hull:1765
    And I should see an inline edit containing "Principles of exercise and training"
	Then I should see "Additional metadata"

