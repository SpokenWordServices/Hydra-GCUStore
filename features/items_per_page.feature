@bug_fix
Feature: Items per page
  In order to verify that the correct per page parameter is being used
  As a user
  I want to get see the correct number of items in the first page of results

  Scenario: 40 item search result default (HYDRASALT-51)
    Given I am on the home page
    Then I should see an "input" tag with a "type" attribute of "hidden"
    And I should not see an "input" tag with a "value" attribute of "20"
    And I should see an "input" tag with a "value" attribute of "40"