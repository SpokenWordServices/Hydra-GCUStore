@show @exam_papers @local
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]

 Scenario: Public visit Publicly Viewable Document
    Given I am on the show document page for hull:1765
    Then I should be on the search page
    And I should see "This material is unavailable. It may have been temporarily or permanently withdrawn, or it may have restricted access. Are you logged in?"
    
Scenario: Staff visits Show Page for Restricted Document
    Given I am logged in as "staff1@example.com" 
    And I am on the show document page for hull:1765
    Then I should see "4207 Principles of exercise and training (April 2009)"
    And I should see "Level 5"
    And I should not see a link to "the edit document page for hull:1765" 

Scenario: Student visits Show Page for Restricted Document
    Given I am logged in as "student1@example.com" 
    And I am on the show document page for hull:3272
    Then I should see "33002 Principles of human movement (May 2009)"
    And I should see "Level 4"
    And I should not see a link to "the edit document page for hull:1765" 

 Scenario: Superuser visits Document Show Page for Restricted Document
    Given I am a superuser
    And I am on the show document page for hull:1765
    Then I should see "4207 Principles of exercise and training (April 2009)"
    And I should see "Level 5"
  
  Scenario: Show view should have search box at top
    Given I am on the show document page for hull:1765
    Then I should see "search"
    And I should see a "input" tag with a "id" attribute of "q"
    
