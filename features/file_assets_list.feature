@file_assets
Feature: List files for a document
  In order to see and manage the files uploaded into a document
  As an editor or non-editor
  I want to see a list of the current files with specified column headings and metadata
  # "Primary" column: Identifies which file is the primary file for the Article submission type
  # "File" column: displays icon identifying file type along with the file name
  # "Description": text describing the file
  # "Size" of file
  # "Uploaded" date and time (YYYY-MM-DD H:MM [A/P])
  # Summary information at bottom of table:
  # In the file column - total number of files
  # In the size column - total size of all uploaded files
  
  Scenario: Editor views the file list
    Given I am logged in as "archivist1@example.com" 
    And I am on the file list page for hydrangea:fixture_mods_article1
    Then I should see a "th" element containing "Primary"
    And I should see a "th" element containing "File"
    And I should see a "th" element containing "Description"
    And I should see a "th" element containing "Size"
    And I should see a "th" element containing "Uploaded"
    # And I should see a "td" with class "file_asset"
    Then I should see a link to "the file asset hydrangea:fixture_uploaded_svg1" with label "OM_MANI_PADME_HUM-bw.svg"    
    Then I should see an inline edit containing "sample file description"
    And I should see a button to delete "the file asset hydrangea:fixture_uploaded_svg1" from "hydrangea:fixture_mods_article1"
    
  Scenario: Non-editor views the file list
    Given I am logged in as "permissionlessdude@example.com" 
    And I am on the file list page for hydrangea:fixture_mods_article1    
    Then I should see a "th" element containing "Primary"
    And I should see a "th" element containing "File"
    And I should see a "th" element containing "Description"
    And I should see a "th" element containing "Size"
    And I should see a "th" element containing "Uploaded"
    Then I should see a link to "the file asset hydrangea:fixture_uploaded_svg1" with label "OM_MANI_PADME_HUM-bw.svg"
    And I should see a "td" element containing "sample file description"
    # Currently, the description is made non-editable by simply not loading the inlineEditable code on this page
    # Then I should not see an inline edit containing "sample file description"
    And I should not see a button to delete "the file asset hydrangea:fixture_uploaded_svg1" from "hydrangea:fixture_mods_article1"
    
    

    