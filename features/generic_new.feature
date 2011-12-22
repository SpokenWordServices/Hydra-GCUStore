@edit
Feature: Generic new
  In order to create a generic content 
  The user
  Needs to be able to fill out a form

  Scenario: Fill out the form 
    Given I am logged in as "contentAccessTeam1@example.com"
    And I am on the new generic content page
    And I fill in "Title" with "My Title"
		And I fill in "Creator" with "Smith, John."
    And I select "Policy or procedure" from "Genre"
    And I press "Create"
    Then I should see "Created My Title"


