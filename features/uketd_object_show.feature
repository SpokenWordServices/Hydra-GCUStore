@show @uketd_objects @local 
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Public visit Publicly Viewable Document
    Given I am on the show document page for hull:3500
    Then I should see "The evolution of accounting in developing countries : the study of Jordan"
    And I should see "Management"
    And I should not see a link to "the edit document page for hull:3500"
 
  @wip
  Scenario: Public visit Document Show Page for a private document  
    Given I am on the show document page for hull:3573
    Then I should be on the search page
    And I should see "You do not have sufficient access privileges to read this document, which has been marked private" within ".notice"
  
  Scenario: Superuser visits Document Show Page for a private document
    Given I am a superuser
    And I am on the show document page for hull:3573
    Then I should see "Kuwait's tax reformation, its alternatives and impact on a developing accounting profession"
  
  Scenario: Archivist visits Show Page for Restricted Document
    Given I am logged in as "archivist1" 
    And I am on the show document page for hull:3500
    Then I should see "The evolution of accounting in developing countries : the study of Jordan"
    And I should not see a link to "the edit document page for hull:3500"

  Scenario: Show view should have search box at top
    Given I am on the show document page for hull:3500
    Then I should see "Search"
    And I should see a "input" tag with a "id" attribute of "q"
 

  @wip
  Scenario: View the contents for the descMetadata stream
    Given I am on the show document page for hull:3112
    Then I should see a link to "the descMetadata datastream content page for hull:3112"
  
 
