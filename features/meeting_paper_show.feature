@show @meeting_papers @local
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]

Scenario: Public visit Publicly Viewable Document
    Given I am on the show document page for hull:3777
    Then I should be on the search page
    And I should see "You do not have sufficient access privileges to read this document, which has been marked private" within ".notice" 

Scenario: Staff visits Show Page for Restricted Document
    Given I am on the show document page for hull:3777
    Then I should be on the search page
    And I should see "You do not have sufficient access privileges to read this document, which has been marked private" within ".notice"
    
Scenario: Staff visits Show Page for Restricted Document
    Given I am on the show document page for hull:3777
    Then I should be on the search page
    And I should see "You do not have sufficient access privileges to read this document, which has been marked private" within ".notice"

Scenario: ContentAccessTeam visits Show Page for Restricted Document
    Given I am logged in as "contentAccessTeam1@example.com" 
    And I am on the show document page for hull:3777
    Then I should see "2010-11-23 Council minutes (Part A)"
    And I should see "Committee Section"
    And I should not see a link to "the edit document page for hull:3337" 

 Scenario: Superuser visits Document Show Page for Restricted Document
    Given I am a superuser
    And I am on the show document page for hull:3777
    Then I should see "2010-11-23 Council minutes (Part A)"
    And I should see "Committee Section"
  
  Scenario: Show view should have search box at top
    Given I am on the show document page for hull:3777
    Then I should see "search"
    And I should see a "input" tag with a "id" attribute of "q"

