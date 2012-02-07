@edit @uketd_objects @local
Feature: QA edit a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
 
  Scenario: Visit Document Edit Page
    Given I am logged in as "contentAccessTeam1@example.com" 
    And I am on the edit document page for hull:756
    Then I should see an inline edit containing "An investigation of the factors which influence the degree"
		And I should not see "Delete resource"
    And I should see a "div" tag with a "class" attribute of "add_contributor_link creator author uketd_object"
    And I should see a "div" tag with a "class" attribute of "add_contributor_link supervisor uketd_object"
    And I should see a "div" tag with a "class" attribute of "add_contributor_link sponsor uketd_object"
    And I should see a "input" tag with a "id" attribute of "person_1_namePart"
    And I should see a "input" tag with a "id" attribute of "person_2_namePart"
    And I should see a "input" tag with a "id" attribute of "organization_0_namePart"
	
  Scenario: Publish a Object in the QA Queue
    Given I am logged in as "contentAccessTeam1@example.com"
    And I am on the edit document page for hull:3573
    When I press "Publish"
    Then I should see "Errors encountered adding"
    Then I select "----Accounting" from "Structural_Set_"
		Then I select "----Accounting" from "Harvesting_Set_"
    And I press "Save metadata"
    Then I should see "Your changes have been saved."
    When I press "Publish"
    Then I should see "Successfully published"

  Scenario: Viewing browse/edit buttons
    Given I am logged in as "contentAccessTeam1@example.com" 
    And I am on the edit document page for hull:756
    Then I should see a "span" tag with a "class" attribute of "edit-browse"
    

