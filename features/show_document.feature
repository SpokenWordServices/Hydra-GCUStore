@show 
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Visit Document Show Page
    Given I am on the edit document page for druid:cm234kq4672
    Then the "Title:" term should contain "Letter from Ellie Engelmore to Wemara Lichty" 
    Then the "Date:" term should contain "1984-6-4" 
    Then the "Document Type:" term should contain "Paper Document"

  Scenario: Donor visits Document Show Page
    Given I am on the edit document page for druid:cm234kq4672
    And I am logged in as "francis"
    Then I should see the "access" value 
    And I should see the "document ID" value 
    And I should see a link to the "raw OCR"
    And I should see a link to the "edit" page
    And related links are displayed as urls