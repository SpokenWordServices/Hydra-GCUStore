@show 
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Public visit Document Show Page
    Given I am on the show document page for druid:sb733gr4073
    Then the "Title:" term should contain "Ahlstrom Annual Report 1991" 
    And the "Date:" term should contain "1991-00-00" 
    And the "Document Type:" term should contain "Paper Document"
    And I should not see the "access" term 
    And I should not see the "document ID" term 
    #And I should not see a link to the "raw OCR"
    And I should not see a link to "the edit document page for druid:cm234kq4672"
  
  Scenario: Public visit Document Show Page for a private document  
    Given I am on the show document page for druid:bz425fy5289
    Then I should be on the search page
    And I should see "You do not have sufficient access privileges to read this document, which has been marked private" within ".notice"

  
  @wip
  Scenario: Donor visits Document Show Page
    Given I am logged in as "francis" on the show document page for druid:cm234kq4672 
    Then I should see the "ID:" term 
    #Then I should see the "access" term 
    #And I should see a link to download "raw OCR"
    And I should see a link to "the edit document page for druid:cm234kq4672"
    And related links are displayed as urls
    
  @wip
  Scenario: Viewing Document with incomplete location info
    Given I am on the show document page for a document with incomplete location info
    Then the location box should have an error saying "Location info is incomplete.  Could not find adjacent documents."