Feature: ETD create and edit
  In order to submit an etd
  The user
  Needs to be able to fill out a form and submit some files

  Scenario: Create an etd and adding grant numnbers
    Given I am logged in as "contentAccessTeam1@example.com"
    And I am on the base search page
    Then I should see "Create Resource"
    When I follow "Create Resource"
    Then I should see "Electronic Thesis or Dissertation"
    When I follow "Electronic Thesis or Dissertation"
    Then I should see "Edit a thesis or dissertation"
    When I follow "Add Grant"
    Then I should see "Add a new grant"
    When I fill in "Add a new grant" with "grant-999"
    And I press "Add Grant"
    Then I should see "grant-999" within "li#grant_number_0-container"
    When I follow "Add Grant"
    And I fill in "Add a new grant" with "grant-888"
    And I press "Add Grant"
    Then I should see "grant-999" within "li#grant_number_0-container"
    Then I should see "grant-888" within "li#grant_number_1-container"

  Scenario: Create an etd and submit to QA
    Given I am logged in as "contentAccessTeam1@example.com"
    And I am on the base search page
    Then I should see "Create Resource"
    When I follow "Create Resource"
    Then I should see "Electronic Thesis or Dissertation"
    When I follow "Electronic Thesis or Dissertation"
    Then I should see "Edit a thesis or dissertation"
    When I press "Submit to QA"
    Then I should see "Errors encountered adding"
    Then I fill in "Publisher (Department, Institution)" with "Test University"
    And I select "Doctoral" from "Qualification level"
    And I select "PhD" from "Qualification name"
    And I press "Save Metadata"
    Then I should see "Your changes have been saved."
    When I press "Submit to QA"
    Then I should see "Successfully added hull"
