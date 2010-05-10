@catalog
Feature: Catalog Index
  As a user
  In order to find the documents I'm searching for
  I want to see my search results in an useful way.

  Scenario: Viewing search results
    Given I am on the catalog index page
    Then I should see "search"