@facets
Feature: display more/less links
  As a user
  In order to hide facets when there are more than the configurable amount
  I want to see more and less li elements

  Scenario: Viewing the facets
    When I am on the home page
    Then I should see "more technologies"
    And I should see "less technologies"