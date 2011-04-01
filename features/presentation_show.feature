@show @presentations @local
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]

 Scenario: Public visit Publicly Viewable Document
    Given I am on the show document page for hull:2107
    Then I should see "The Hydra initiative : Underpinning repository interaction for research support"
    And I should see "Awre, Christopher L"
    And I should not see a link to "the edit document page for hull:2107" 
    
Scenario: Staff visits Show Page for Restricted Document
    Given I am logged in as "staff1" 
    And I am on the show document page for hull:2107
    Then I should see "The Hydra initiative : Underpinning repository interaction for research support"
    And I should see "Awre, Christopher L"
    And I should not see a link to "the edit document page for hull:2107" 

Scenario: Student visits Show Page for Restricted Document
    Given I am logged in as "student1" 
    And I am on the show document page for hull:2107
    Then I should see "The Hydra initiative : Underpinning repository interaction for research support"
    And I should see "Awre, Christopher L"
    And I should not see a link to "the edit document page for hull:2107" 

 Scenario: Superuser visits Document Show Page for Restricted Document
    Given I am a superuser
    And I am on the show document page for hull:2107
    Then I should see "The Hydra initiative : Underpinning repository interaction for research support"
    And I should see "Awre, Christopher L"
  
  Scenario: Show view should have search box at top
    Given I am on the show document page for hull:2107
    Then I should see "search"
    And I should see a "input" tag with a "id" attribute of "q"
 
