@show @exam_papers @local
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]

 Scenario: Public visit Publicly Viewable Document
    Given I am on the show document page for hull:1765
    Then I should be on the search page
    And I should see "You do not have sufficient access privileges to read this document, which has been marked private" within ".notice"
    
Scenario: Archivist visits Show Page for Restricted Document
    Given I am logged in as "staff1" 
    And I am on the show document page for hull:1765
    Then I should see "4207 Principles of exercise and training (2008/2009)"
    And I should see "Level 5 examination: 2008/2009"
    And I should not see a link to "the edit document page for hull:1765" 

 Scenario: Superuser visits Document Show Page for Restricted Document
    Given I am a superuser
    And I am on the show document page for hull:1765
    Then I should see "4207 Principles of exercise and training (2008/2009)"
    And I should see "Level 5 examination: 2008/2009"
