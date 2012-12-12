@edit
Feature: Admin user can add a licence
  In order to create a licence 
  The admin user
  Needs to fill out a form


  Scenario: Create a licence 
    Given I am logged in as "contentAccessTeam1@example.com"
    And I am on the new licence page
    And I fill in "Name" with "My Licence"
    And I fill in "Link" with "http://www.spokenword.ac.uk"
    And I press "Save"
    Then I should see "New Licence Created"


