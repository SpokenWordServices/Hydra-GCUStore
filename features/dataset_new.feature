@edit
Feature: Dataset new
  In order to create a new Dataset 
  The user
  Needs to be able to fill out a form

  Scenario: Fill out the form 
    Given I am logged in as "contentAccessTeam1@example.com"
    And I am on the new generic content page
    And I fill in "Title" with "Large dataset of marine fisheries"
	  And I fill in "Creator" with "Smith, John."
    And I select "Creator" from "Role"
    And I select "Dataset" from "Genre"
    And I press "Create"
    Then I should see "Created Large dataset of marine fisheries with pid"
    And I should see "Dataset"
    And I should see "Edit content"
    Then I fill in "Version" with "1.5"
    And I fill in "Description" with "This is dataset containing a huge amount of Fisheries dataset"
    And I fill in "Publisher" with "University Of Hull"
    And I fill in "Publication year (YYYY)" with "2010"
    And I fill in "DOI" with "hull/132423/87"
    And I press "Save metadata"
    Then I should see "Your changes have been saved."
