@show @journal_articles @local
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]

  
Scenario: Public visit Publicly Viewable Document
    Given I am on the show document page for hull:1729
    Then I should see "Towards a Repository-enabled Scholars Workbench : RepoMMan, REMAP and Hydra"
    And I should see "Green, Richard A.; Awre, Christopher L."
    #And I should see "Repositories; RepoMMan; REMAP; Hydra"
    And I should not see a link to "the edit document page for hull:1729" 

Scenario: Public visits Show Page for Restricted Document
    Given I am on the show document page for hull:2376
    Then I should be on the search page
    And I should see "You do not have sufficient access privileges to read this document, which has been marked private" within ".notice"
   
Scenario: Staff visits Show Page for Restricted Document
    Given I am logged in as "staff1@example.com" 
    And I am on the show document page for hull:2376
    Then I should see "Valid knowledge: the economy and the academy"
    And I should see "Williams, Peter"
    And I should see "Forms of knowledge; University futures; Learning technologies; Knowledge economy"
    And I should not see a link to "the edit document page for hull:2376" 

Scenario: Student visits Show Page for Restricted Document
    Given I am logged in as "student1@example.com" 
    And I am on the show document page for hull:2376
    Then I should see "Valid knowledge: the economy and the academy"
    And I should see "Williams, Peter"
    And I should see "Forms of knowledge; University futures; Learning technologies; Knowledge economy"
    And I should not see a link to "the edit document page for hull:2376" 

 Scenario: Superuser visits Document Show Page for Restricted Document
    Given I am a superuser
    And I am on the show document page for hull:2376
    Then I should see "Valid knowledge: the economy and the academy"
    And I should see "Williams, Peter"
    And I should see "Forms of knowledge; University futures; Learning technologies; Knowledge economy"
  
  Scenario: Show view should have search box at top
    Given I am on the show document page for hull:1729
    Then I should see "search"
    And I should see a "input" tag with a "id" attribute of "q"
   
