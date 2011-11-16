@edit
Feature: Generic edit
  In order to submit a change
  The user
  Needs to be able to fill out a form

  Scenario: Change the valid date on a generic object
    Given I am logged in as "contentAccessTeam1@example.com"
    And I am on the edit page for id hull:999
    Then I should see "Valid Date"
    When I fill in "Valid Date" with "2011-08-22/2012-08-30"
    And I press "Save"
    Then I should see "Your changes have been saved."
    And I should see an inline edit containing "2011-08-22/2012-08-30"

