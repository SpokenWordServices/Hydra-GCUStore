Feature: Items per page
  In order to verify that the correct per page parameter is being used
  As a user
  I want to get see the correct number of items in the first page of results

  Scenario: 40 item search result default (HYDRASALT-51)
    Given I am on the home page
    Then I should see 40 gallery results
    When I fill in "q" with "intelligence"
    And I press "search"
  	Then I should see 40 gallery results
    When I follow "EDWARD FEIGENBAUM"
    Then I should see 40 gallery results
    When I follow "List"
    Then I should see 40 list results