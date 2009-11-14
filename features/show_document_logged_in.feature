@show @wip
Feature: Show a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Donor visits Document Show Page
    Given I am on the show document page for druid:cm234kq4672
    And I am logged in as "francis"
    And I should see the "ID:" term 
    Then I should see the "access" term 
    #And I should see a link to download "raw OCR"
    And I should see a link to the "edit" page
    And related links are displayed as urls