@create @split_button @pending
Feature: Create Asset or Dataset Split Button
  In order to create new Assets or Datasets
  As an editor 
  I want to see a button that will let me create a new Article or Dataset
  
  Scenario: Editor views the search results page and sees the add article button
    Given I am logged in as "archivist1@example.com" 
    Given I am on the base search page
    Then I should see "Add an article" within "div#create-asset-box"
    And I should see "Add a dataset" within "div#create-asset-box"
    
    
  Scenario: Non-editor views the search results page and does not see the add article button
    Given I am on the base search page
    Then I should not see "Add an article" 
    And I should not see "Add a dataset"
  
