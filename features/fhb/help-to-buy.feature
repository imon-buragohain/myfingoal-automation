Feature: Help to Buy eligibility across Australian states

  As a first home buyer
  I want to know if I am eligible for Help to Buy
  So that I can consider the shared equity option

  Background:
    Given I am on the First Home Buyer planner

  @smoke @fhb @htb
  Scenario: Eligible individual under income cap is approved for Help to Buy
    Given I am buying as a "Individual" "Citizen" in "QLD"
    And I enter a salary of "$90,000"
    And the property is a "Established" valued at "$650,000"
    And I enter a contract month of "2026-04"
    When I calculate my first home buyer plan
    Then Help to Buy should be "eligible"

  @smoke @fhb @htb
  Scenario: Individual over $100k income cap is not eligible for Help to Buy
    Given I am buying as a "Individual" "Citizen" in "QLD"
    And I enter a salary of "$101,000"
    And the property is a "New" valued at "$650,000"
    And I enter a contract month of "2026-04"
    When I calculate my first home buyer plan
    Then Help to Buy should be "not eligible"

  @smoke @fhb @htb
  Scenario: Permanent Resident is not eligible for Help to Buy
    Given I am buying as a "Individual" "PR" in "QLD"
    And I enter a salary of "$80,000"
    And the property is a "New" valued at "$600,000"
    And I enter a contract month of "2026-04"
    When I calculate my first home buyer plan
    Then Help to Buy should be "not eligible"

  @smoke @fhb @htb
  Scenario: WA buyer is not eligible — state not participating
    Given I am buying as a "Individual" "Citizen" in "WA"
    And I enter a salary of "$70,000"
    And the property is a "Established" valued at "$480,000"
    And I enter a contract month of "2026-04"
    When I calculate my first home buyer plan
    Then Help to Buy should be "not eligible"

  @regression @fhb @htb
  Scenario Outline: Help to Buy eligibility — Excel driven
    Given I am buying as a "<family_type>" "<residency>" in "<state>"
    And I enter a salary of "<salary>"
    And the property is a "<property_type>" valued at "<price>"
    And I enter a contract month of "<contract_month>"
    When I calculate my first home buyer plan
    Then Help to Buy should be "<expected_htb>"

    Examples:
      | family_type | residency | state | salary   | property_type | price      | contract_month | expected_htb |
      | Individual  | Citizen   | QLD   | $90,000  | Established   | $650,000   | 2026-04        | eligible     |
      | Couple      | Citizen   | QLD   | $165,000 | New           | $750,000   | 2026-04        | not eligible |
      | Individual  | PR        | QLD   | $80,000  | New           | $600,000   | 2026-04        | not eligible |
      | Individual  | Citizen   | WA    | $70,000  | Established   | $480,000   | 2026-04        | not eligible |
      | Couple      | Citizen   | NSW   | $150,000 | New           | $780,000   | 2026-04        | eligible     |
      | Couple      | Citizen   | NSW   | $150,000 | New           | $1,400,000 | 2026-04        | not eligible |
      | Individual  | Citizen   | VIC   | $70,000  | New           | $580,000   | 2026-04        | eligible     |
      | Couple      | Citizen   | ACT   | $250,000 | New           | $900,000   | 2026-04        | not eligible |