@edit
Feature: Dataset edit
  In order to submit a change
  The user
  Needs to be able to fill out a form

  Scenario: Change the coordinates on a Dataset
    Given I am logged in as "contentAccessTeam1@example.com"
    And I am on the edit page for id hull:2155
    Then I should see "Coordinates text"
    When I fill in "Coordinates text" with "World Whaling areas"
    And I fill in "Coordinates" with "0.580591,53.785744,0.000000 -0.578907,53.785606,0.000000 -0.577995,53.785629,0.000000 -0.576847,53.785648,0.000000 -0.576203,53.785763,0.000000"
    And I press "Save"
    Then I should see "Encountered the following errors: descMetadata error: a valid coordinates type has not been specified"
    When I fill in "Coordinates text" with "World Whaling areas"
    And I select "Polygon" from "Coordinates type"
    And I fill in "Coordinates" with "0.580591,53.785744,0.000000 -0.578907,53.785606,0.000000 -0.577995,53.785629,0.000000 -0.576847,53.785648,0.000000 -0.576203,53.785763,0.000000"
    And I press "Save"
    Then I should see "Your changes have been saved."
  
