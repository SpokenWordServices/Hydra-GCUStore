@catalog
Feature: Homepage
  As a user
  In order to begin using the application
  I want to visit the homepage

  Scenario: Visiting home page
    Given I am on the home page
    Then I should see "search"
		And I should not see "Create Resource"

  Scenario: Student visiting home page should not see create resources link 
    Given I am logged in as "student1@example.com"
    Then I should see "search"
		And I should not see "Create Resource"

	Scenario: contentAccessTeam1 visiting home page
    Given I am logged in as "contentAccessTeam1@example.com"
		Then I should see "search"
		And I should see "Create Resource"
