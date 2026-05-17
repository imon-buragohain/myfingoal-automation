Feature: Personal details and income entry for single and couple scenarios

  As a property owner planning my financial future
  I want to enter my personal details and income accurately
  So that my calculations reflect my actual situation

  Background:
    Given I am on the Property Owner planner

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @property-owner @personal-details
  Scenario: Enter details for a single person
    When I select "Individual" as the planning type
    And I enter Person 1 first name as "Alex"
    And I enter Person 1 current age as "42"
    And I enter Person 1 planned retirement age as "63"
    And I enter Person 1 annual salary as "$120,000"
    And I toggle "Salary includes Superannuation" to "on"
    And I enter Person 1 current super balance as "$180,000"
    And I enter Person 1 super rate as "12.0"
    And I click Calculate
    Then the results page should display without error
    And Person 2 section should not be visible

  @smoke @property-owner @personal-details
  Scenario: Super rate field defaults to 12.0 percent with ATO minimum helper text
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I view the Super Rate field
    Then the field should show "12.0"
    And helper text should state "ATO minimum is 12% for 2025-26"

  @smoke @property-owner @personal-details
  Scenario: Salary includes Superannuation toggle shows division helper
    When I select "Individual" as the planning type
    And I enter Person 1 annual salary as "$120,000"
    And I toggle "Salary includes Superannuation" to "on"
    Then helper text should state the salary will be divided by "1.12" to get base salary
    And the base salary should be calculated as "$120,000 / 1.12 = $107,143"

  # ─────────────────────────────────────────────
  # REGRESSION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @property-owner @personal-details
  Scenario: Enter details for a couple with different retirement ages
    When I select "Couple" as the planning type
    And I enter Person 1 first name as "Jack"
    And I enter Person 1 current age as "38"
    And I enter Person 1 planned retirement age as "60"
    And I enter Person 1 annual salary as "$110,000"
    And I enter Person 1 current super balance as "$85,000"
    And I enter Person 2 first name as "Jill"
    And I enter Person 2 current age as "41"
    And I enter Person 2 planned retirement age as "60"
    And I enter Person 2 annual salary as "$90,000"
    And I enter Person 2 current super balance as "$75,000"
    And I click Calculate
    Then the results page should display without error
    And Person 2 section should be visible in the form

  @regression @property-owner @personal-details
  Scenario: Results show both partners' super balances separately for couple
    Given I am on the Property Owner planner
    When I select "Couple" as the planning type
    And I enter Person 1 first name as "Jack"
    And I enter Person 1 current age as "38"
    And I enter Person 1 planned retirement age as "60"
    And I enter Person 1 annual salary as "$110,000"
    And I enter Person 1 current super balance as "$85,000"
    And I enter Person 2 first name as "Jill"
    And I enter Person 2 current age as "41"
    And I enter Person 2 planned retirement age as "60"
    And I enter Person 2 annual salary as "$90,000"
    And I enter Person 2 current super balance as "$75,000"
    And I click Calculate
    Then the Superannuation Summary should show "Jack super at retirement"
    And the Superannuation Summary should show "Jill super at retirement"
    And a "Combined super balance" row should be visible

  @regression @property-owner @personal-details
  Scenario: Years to retirement displays automatically below retirement age field
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "42"
    And I enter Person 1 planned retirement age as "63"
    Then below the retirement age field should display "21 years until retirement"

  @regression @property-owner @personal-details
  Scenario: Current age field rejects values above 80
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "90000"
    Then an inline red error should appear below the Current Age field
    And the error should state "Age must be 80 or under"
    And the Calculate button should be disabled

  @regression @property-owner @personal-details
  Scenario: Current age field rejects values below 18
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "17"
    Then an inline red error should appear below the Current Age field
    And the error should state "Age must be 18 or over"

  @regression @property-owner @personal-details
  Scenario: Retirement age must be greater than current age
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "45"
    And I enter Person 1 planned retirement age as "40"
    Then an inline red error should appear
    And the error should state "Retirement age must be greater than current age"
    And the Calculate button should be disabled

  @regression @property-owner @personal-details
  Scenario: Correcting an invalid age removes the error and enables Calculate
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "90000"
    And an error appears below the Current Age field
    And I correct the age to "42"
    Then the error message should disappear
    And the Calculate button should be enabled

  @regression @property-owner @personal-details
  Scenario: Super return rate change is reflected in calculation explanations
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$120,000"
    And I enter Person 1 current super balance as "$150,000"
    And I set the super annual gross return assumption to "6.0"
    And I click Calculate
    And I expand "How we calculated this" in the Superannuation Summary
    Then the explanation text should show "6.0% gross annual return"
    And the text should not show hardcoded "8.5%"

  @regression @property-owner @personal-details
  Scenario: Super return rate change to 7.5 percent updates explanations
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$120,000"
    And I enter Person 1 current super balance as "$150,000"
    And I set the super annual gross return assumption to "7.5"
    And I click Calculate
    And I expand "How we calculated this" in the Superannuation Summary
    Then the explanation text should show "7.5% gross annual return"

  @regression @property-owner @personal-details
  Scenario: Selecting Individual hides all Person 2 fields
    When I select "Couple" as the planning type
    And Person 2 section is visible
    And I select "Individual" as the planning type
    Then Person 2 section should be hidden completely
    And all Person 2 input fields should not be visible

  @regression @property-owner @personal-details
  Scenario: Current super balance field includes helper text about verification
    When I select "Individual" as the planning type
    And I view the Current Super Balance field
    Then helper text should state "Check your super fund app or last annual statement"

  @regression @property-owner @personal-details
  Scenario Outline: Age field accepts valid numbers within allowed range
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "<current_age>"
    And I enter Person 1 planned retirement age as "<retirement_age>"
    Then no age validation error should appear

    Examples:
      | current_age | retirement_age |
      | 18          | 65             |
      | 40          | 70             |
      | 55          | 80             |
      | 80          | 85             |
