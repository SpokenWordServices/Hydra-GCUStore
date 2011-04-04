@catalog
Feature: Catalog Index
  As a user
  In order to find the documents I'm searching for
  I want to see my search results in an useful way.

  Scenario: Viewing search results
    Given I am on the catalog index page
    Then I should see "search"

  @overwritten
  Scenario: Executing a search
    Given I am on the catalog index page
    And I fill in "q" with "hydrangea"
    And I press "search"
    Then I should see "Display as"
#    And I should see "Title"
    And I should see "Creator"
    And I should see "Type"
    And I should see "files"
    And I should see "Status"
    When I select "list" from "display_type"
    And I press "display_results"
    Then I should see "Author"
    And I should see "Researcher"
    And I should see "Sample file description. 1 file."

  @local
  Scenario: Executing a search
    Given I am on the catalog index page
    And I fill in "q" with "evolution"
    And I press "search"
    Then I should see "2 documents"
    And I should see "Sort by"
    And I should see "Show"
    And I should not see "Display as"
    And I should see "Resource type"
    And I should see "Author"
    And I should see "Subject"
    And I should see "Language"
