Feature: Investment property with negative gearing and loan options

  As a property investor
  I want to enter my investment property details accurately
  So that I can see the correct negative gearing treatment and retirement income

  Background:
    Given I am on the Property Owner planner
    And I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$120,000"

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @property-owner @investment-property
  Scenario: Add an investment property with negative gearing
    When I enable the Investment Property section
    And I enter the IP property purchase price as "$1,350,000"
    And I enter the IP loan amount as "$1,100,000"
    And I enter the IP annual interest rate as "6.1"
    And I enter the IP months remaining as "340"
    And I enter the IP weekly rental income as "$1,000"
    And I enter the IP annual council rates as "$2,200"
    And I enter the IP annual water rates as "$1,000"
    And I enter the IP annual insurance as "$2,000"
    And I enter the IP annual repairs and maintenance as "$2,000"
    And I enter the IP property agent fee as "7.5"
    And I enter the IP annual depreciation as "$5,000"
    And I calculate my property owner plan
    Then the Results page should display without error
    And the IP rental income row should appear in the Retirement Income Breakdown
    And the IP rental income should be shown as "net of costs"

  @smoke @property-owner @investment-property
  Scenario: Interest Only loan option for investment property
    When I enable the Investment Property section
    And I enter the IP loan amount as "$1,100,000"
    And I enter the IP annual interest rate as "6.1"
    And I enter the IP months remaining as "340"
    And I select "Interest Only" as the IP loan type
    And I select "5 years" as the IO period
    Then a green info box should show "IO payment:" and "P&I after reversion:"
    And the IO payment should be approximately "$5,592"
    And the P&I payment after reversion should be approximately "$7,375"

  @smoke @property-owner @investment-property
  Scenario: Weekly rental income converts to monthly equivalent
    When I enable the Investment Property section
    And I enter the IP weekly rental income as "$1,000"
    Then a live display should show "Monthly equivalent: $4,333"

  # ─────────────────────────────────────────────
  # REGRESSION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @property-owner @investment-property
  Scenario: Interest Only loan hides IP offset balance field
    When I enable the Investment Property section
    And I select "Interest Only" as the IP loan type
    Then the "Current IP Offset Account Balance" field should be hidden

  @regression @property-owner @investment-property
  Scenario: Interest Only loan hides IP offset phase from savings allocation
    When I enable the Investment Property section
    And I enter the IP loan amount as "$1,100,000"
    And I enter the IP annual interest rate as "6.1"
    And I enter the IP months remaining as "340"
    And I select "Interest Only" as the IP loan type
    And I view the Savings Allocation section
    Then the IP offset phase should not be visible

  @regression @property-owner @investment-property
  Scenario: Principal and Interest loan shows IP offset option in savings
    When I enable the Investment Property section
    And I enter the IP loan amount as "$1,100,000"
    And I enter the IP annual interest rate as "6.1"
    And I enter the IP months remaining as "340"
    And I select "Principal & Interest" as the IP loan type
    And I view the Savings Allocation section
    Then a Phase 2 panel should be visible for "IP offset"

  @regression @property-owner @investment-property
  Scenario: Property agent fee calculation shows live annual and monthly equivalent
    When I enable the Investment Property section
    And I enter the IP weekly rental income as "$1,000"
    And I enter the IP property agent fee as "7.5"
    Then a display should show "Annual agent fees: $3,900"
    And a display should show "$325/mo"

  @regression @property-owner @investment-property
  Scenario: Net rental income in retirement excludes running costs
    When I enable the Investment Property section
    And I enter the IP weekly rental income as "$1,000"
    And I enter the IP annual council rates as "$2,200"
    And I enter the IP annual water rates as "$1,000"
    And I enter the IP annual insurance as "$2,000"
    And I enter the IP annual repairs and maintenance as "$2,000"
    And I enter the IP property agent fee as "7.5"
    And I calculate my property owner plan
    And I view the Retirement Income Breakdown section
    Then the IP rental income row should show approximately "$3,408/mo"
    And sub-rows should show gross rent and running costs separately
    And the value should be less than the monthly equivalent rent of "$4,333"

  @regression @property-owner @investment-property
  Scenario: IP breakdown shows gross rent and running costs as sub-rows
    When I enable the Investment Property section
    And I enter the IP weekly rental income as "$1,000"
    And I enter the IP annual council rates as "$2,200"
    And I enter the IP annual water rates as "$1,000"
    And I enter the IP annual insurance as "$2,000"
    And I enter the IP annual repairs and maintenance as "$2,000"
    And I enter the IP property agent fee as "7.5"
    And I calculate my property owner plan
    And I expand the IP rental income row details
    Then a sub-row should show "Gross rent: $4,333/mo"
    And a sub-row should show "Running costs: -$925/mo"
    And the parent row should show "Net: $3,408/mo"

  @regression @property-owner @investment-property
  Scenario: Results page shows loan type: Interest Only with reversion info
    When I enable the Investment Property section
    And I enter the IP loan amount as "$1,100,000"
    And I enter the IP annual interest rate as "6.1"
    And I enter the IP months remaining as "340"
    And I select "Interest Only" as the IP loan type
    And I select "5 years" as the IO period
    And I calculate my property owner plan
    Then the Mortgage and Offset Summary should show "IP loan type: Interest Only (5yr) → P&I"
    And the IO monthly repayment should be shown as "$5,592"
    And the P&I repayment after reversion should be shown with reversion age

  @regression @property-owner @investment-property
  Scenario: Retirement income chart shows amber property income bars
    When I enable the Investment Property section
    And I enter the IP weekly rental income as "$1,000"
    And I enter the IP loan amount as "$1,100,000"
    And I enter the IP annual interest rate as "6.1"
    And I calculate my property owner plan
    Then the Retirement Income by Source chart should display amber bars for property income
    And the amber bars should appear from retirement age onwards

  @regression @property-owner @investment-property
  Scenario Outline: Negative gearing deductibles are captured with live calculations
    When I enable the Investment Property section
    And I enter the IP weekly rental income as "$1,000"
    And I enter the IP annual "<deductible_type>" as "<amount>"
    Then the correct annual total should be displayed

    Examples:
      | deductible_type | amount |
      | council rates   | $2,200 |
      | water rates     | $1,000 |
      | insurance       | $2,000 |

  @regression @property-owner @investment-property
  Scenario: Calculate without investment property produces valid results
    When I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$120,000"
    And the Investment Property section is disabled
    And I calculate my property owner plan
    Then the Results page should display without error
    And no IP rental income row should appear in the Retirement Income Breakdown
    And no amber "Property income" bars should appear in the Retirement Income by Source chart
    And the Wealth Breakdown hard assets table should show only primary home equity
