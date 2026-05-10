Feature: First Home Owner Grant eligibility across Australian states

  As a first home buyer
  I want to know if I am eligible for the First Home Owner Grant
  So that I can include it in my deposit planning

  Background:
    Given I am on the First Home Buyer planner

  @smoke @fhb @fhog
  Scenario: QLD new home before FHOG reversion receives $30,000 grant
    Given I am buying as a "Couple" "Citizen" in "QLD"
    And I enter a combined salary of "$165,000"
    And the property is a "New" valued at "$750,000"
    And I enter a contract month of "2026-06"
    When I calculate my first home buyer plan
    Then the First Home Owner Grant should be "$30,000"

  @smoke @fhb @fhog
  Scenario: QLD new home after FHOG reversion receives $15,000 grant
    Given I am buying as a "Couple" "Citizen" in "QLD"
    And I enter a combined salary of "$165,000"
    And the property is a "New" valued at "$750,000"
    And I enter a contract month of "2026-08"
    When I calculate my first home buyer plan
    Then the First Home Owner Grant should be "$15,000"

  @smoke @fhb @fhog
  Scenario: Permanent Resident is also eligible for FHOG
    Given I am buying as a "Individual" "PR" in "QLD"
    And I enter a salary of "$80,000"
    And the property is a "New" valued at "$600,000"
    And I enter a contract month of "2026-04"
    When I calculate my first home buyer plan
    Then the First Home Owner Grant should be "$30,000"

  @regression @fhb @fhog
  Scenario Outline: FHOG eligibility across states — Excel driven
    Given I am buying as a "<family_type>" "<residency>" in "<state>"
    And I enter a salary of "<salary>"
    And the property is a "<property_type>" valued at "<price>"
    And I enter a contract month of "<contract_month>"
    When I calculate my first home buyer plan
    Then the First Home Owner Grant should be "<expected_fhog>"

    Examples:
      | family_type | residency | state | salary   | property_type | price    | contract_month | expected_fhog |
      | Couple      | Citizen   | QLD   | $165,000 | New           | $750,000 | 2026-06        | $30,000       |
      | Couple      | Citizen   | QLD   | $165,000 | New           | $750,000 | 2026-08        | $15,000       |
      | Individual  | Citizen   | NSW   | $80,000  | New           | $780,000 | 2026-04        | $10,000       |
      | Individual  | Citizen   | VIC   | $70,000  | New           | $580,000 | 2026-04        | $10,000       |
      | Individual  | Citizen   | SA    | $70,000  | New           | $550,000 | 2026-04        | $15,000       |
      | Individual  | Citizen   | TAS   | $70,000  | New           | $600,000 | 2026-04        | $30,000       |
      | Individual  | Citizen   | NT    | $80,000  | New           | $700,000 | 2026-04        | $50,000       |
      | Couple      | Citizen   | ACT   | $150,000 | New           | $950,000 | 2026-04        | $0            |