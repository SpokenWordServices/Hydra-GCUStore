@edit 
Feature: Edit a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Visit Document Edit Page
    Given I am logged in as "francis" on the edit document page for druid:sb733gr4073     
    Then the "Date:" inline date edit should contain "1991-00-00"
    And the "Type:" dropdown edit should contain "Paper document"
    ## Commented out next line b/c the title is not displaying properly due to a bug in the sample data on the testing image.
    # And the "Title:" inline edit should contain "Letter from Ellie Engelmore to Wemara Lichty"

  Scenario: Viewing browse/edit buttons
    Given I am logged in as "francis" on the edit document page for druid:sb733gr4073
    Then I should see a "span" tag with a "class" attribute of "edit-browse"
    # 
    # When I fill in "Name" with "name 1"
    # And I fill in "Color" with "color 1"
    # And I fill in "Description" with "description 1"
    # And I press "Create"
    # Then I should see "name 1"
    # And I should see "color 1"
    # And I should see "description 1"

  # Scenario: Delete frooble
  #   Given the following froobles:
  #     |name|color|description|
  #     |name 1|color 1|description 1|
  #     |name 2|color 2|description 2|
  #     |name 3|color 3|description 3|
  #     |name 4|color 4|description 4|
  #   When I delete the 3rd frooble
  #   Then I should see the following froobles:
  #     |Name|Color|Description|
  #     |name 1|color 1|description 1|
  #     |name 2|color 2|description 2|
  #     |name 4|color 4|description 4|
