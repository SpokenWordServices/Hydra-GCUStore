@edit 
Feature: Edit a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Visit Document Edit Page
    Given I am on the edit document page for druid:cm234kq4672
    Then the "Title:" inline edit should contain "Letter from Ellie Engelmore to Wemara Lichty"
    And the "Date:" inline edit should contain "1984-6-4"
    And the "Document Type:" inline edit should contain "Paper Document"

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
