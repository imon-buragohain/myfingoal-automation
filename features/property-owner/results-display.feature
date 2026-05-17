Feature: Results page display, charts and wealth breakdown

  As a user reviewing my financial plan
  I want to see clear results with accurate charts and wealth breakdown
  So that I can understand my financial security and make informed decisions

  Background:
    Given I am on the Property Owner planner
    And I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$120,000"
    And I enter Person 1 current super balance as "$150,000"
    And I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @property-owner @results
  Scenario: Results page KPI cards show four key financial metrics
    When I calculate my property owner plan
    Then the results page should display without error
    And four KPI cards should be visible without scrolling
    And a "Monthly surplus" card should show a positive dollar amount
    And a "Super at retirement" card should be present
    And a "Net worth at retirement" card should be present
    And a "Monthly retirement income" card should be present
    And all card values should be formatted with "$" prefix

  @smoke @property-owner @results
  Scenario: Wealth Breakdown correctly splits liquid and hard assets
    When I calculate my property owner plan
    And I view the Wealth Breakdown at Retirement section
    Then a progress bar should show "Liquid X% | Hard Y%"
    And the liquid assets table should show super, cash & HISA, and investments
    And the hard assets table should show primary home equity
    And a footnote should explain liquid assets fund retirement income

  @smoke @property-owner @results
  Scenario: Footer buttons allow editing and downloading
    When I calculate my property owner plan
    And I view the footer
    Then an "← Edit Inputs" button should be present
    And a "↓ Download PDF" button should be present
    And a "↓ Download Excel" button should be present

  # ─────────────────────────────────────────────
  # REGRESSION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @property-owner @results
  Scenario: KPI cards are formatted correctly with abbreviations
    When I calculate my property owner plan
    And I view the KPI cards
    Then values should use "$" prefix for currency
    And large values should use "K" for thousands (e.g., "$1,234K")
    And very large values should use "M" for millions (e.g., "$1.2M")

  @regression @property-owner @results
  Scenario: Mobile layout displays KPI cards in 2x2 grid
    When I set the viewport width to "390"
    And I calculate my property owner plan
    Then the four KPI cards should display in a "2x2" grid
    And no card should overflow horizontally

  @regression @property-owner @results
  Scenario: Balance Projection chart shows complete wealth picture
    When I calculate my property owner plan
    And I view the Balance Projection chart
    Then the chart title should be "Balance Projection — All Assets Over Time"
    And the X-axis should show ages from current age to 100
    And bars during accumulation should show growing asset stacks
    And bars during retirement should show declining liquid assets

  @regression @property-owner @results
  Scenario: Balance Projection chart shows retirement age markers
    When I select "Couple" as the planning type
    And I enter Person 1 first name as "Jack"
    And I enter Person 2 first name as "Jill"
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "60"
    And I enter Person 2 current age as "38"
    And I enter Person 2 planned retirement age as "65"
    And I calculate my property owner plan
    And I view the Balance Projection chart
    Then vertical dashed lines should mark retirement ages
    And the lines should be labelled "Jack retires" and "Jill retires"

  @regression @property-owner @results
  Scenario: Balance Projection chart shows Super runs out line if applicable
    When I calculate my property owner plan
    And I view the Balance Projection chart
    And super depletes before age 100
    Then a red dashed line should appear at the depletion age
    And the line should be labelled "Super runs out"

  @regression @property-owner @results
  Scenario: Balance Projection chart tooltip shows asset breakdown
    When I calculate my property owner plan
    And I view the Balance Projection chart
    When I hover over any bar
    Then a tooltip should show breakdown by asset type
    And the tooltip should show individual dollar amounts for each asset class

  @regression @property-owner @results
  Scenario: Balance Projection chart updates when lifestyle slider moves
    When I calculate my property owner plan
    And I view the Balance Projection chart and Retirement Lifestyle Simulator
    And I note the current super runs out age
    When I drag the lifestyle slider down by "20%"
    Then the Balance Projection chart should update
    And the "Super runs out" line should move right

  @regression @property-owner @results
  Scenario: Retirement Income Breakdown shows all income sources as separate rows
    When I calculate my property owner plan
    And I view the Retirement Income Breakdown section
    Then a row should show super drawdown
    And a row should show IP rental income if applicable
    And a row should show Age Pension
    And a "Total monthly income" row should equal the sum of all rows

  @regression @property-owner @results
  Scenario: Retirement Income Breakdown total matches chart tooltip
    When I calculate my property owner plan
    And I view the Retirement Income Breakdown total
    And I note the total monthly income value
    When I view the Retirement Income by Source chart at retirement age
    Then the chart tooltip should show "Total: [same value]"

  @regression @property-owner @results
  Scenario: Retirement Income by Source chart shows ASFA reference line
    When I calculate my property owner plan
    And I view the Retirement Income by Source chart
    Then a dashed reference line should be visible
    And the line should be labelled as "ASFA comfortable retirement"

  @regression @property-owner @results
  Scenario: Retirement Income by Source chart updates with lifestyle slider
    When I calculate my property owner plan
    And I view the Retirement Income by Source chart and Retirement Lifestyle Simulator
    When I drag the lifestyle slider up by "25%"
    Then the chart bars should increase in height
    And all income source bars should update proportionally

  @regression @property-owner @results
  Scenario: Wealth Breakdown hard assets table shows IP equity when entered
    When I enable the Investment Property section
    And I enter the IP property purchase price as "$1,350,000"
    And I enter the IP loan amount as "$1,100,000"
    And I calculate my property owner plan
    And I view the Wealth Breakdown hard assets table
    Then a row should show "IP equity"
    And the value should be positive

  @regression @property-owner @results
  Scenario: Wealth Breakdown hard assets table hides IP equity when not entered
    When the Investment Property section is disabled
    And I calculate my property owner plan
    And I view the Wealth Breakdown hard assets table
    Then no IP equity row should appear
    And only primary home equity should be visible

  @regression @property-owner @results
  Scenario: Clicking Edit Inputs returns to form with all values preserved
    When I calculate my property owner plan
    And I click the "← Edit Inputs" button
    Then the form should display with all previously entered values
    And Person 1 first name should be populated
    And Person 1 current age should be "40"
    And Person 1 planned retirement age should be "65"
    And Person 1 annual salary should be "$120,000"

  @regression @property-owner @results
  Scenario: Editing a value and recalculating shows updated results
    When I calculate my property owner plan
    And I click the "← Edit Inputs" button
    And I change Person 1 annual salary to "$150,000"
    And I click Calculate
    Then the Monthly Surplus KPI should increase
    And all other results should update to reflect the higher salary

  @regression @property-owner @results
  Scenario: Download PDF button initiates a download
    When I calculate my property owner plan
    And I click the "↓ Download PDF" button
    Then either a file download should start
    Or a loading/spinner indicator should appear
    And no error message should be shown

  @regression @property-owner @results
  Scenario: Download Excel button initiates a download
    When I calculate my property owner plan
    And I click the "↓ Download Excel" button
    Then either a file download should start
    Or a loading/spinner indicator should appear
    And no error message should be shown

  @regression @property-owner @results
  Scenario: Mobile footer buttons are tappable without zooming
    When I set the viewport width to "390"
    And I calculate my property owner plan
    And I scroll to the footer
    Then all three footer buttons should be visible
    And no button should require horizontal scrolling
    And all buttons should be tappable at their normal size

  @regression @property-owner @results
  Scenario: Retirement Income by Source chart shows couple transition correctly
    When I select "Couple" as the planning type
    And I enter Person 1 first name as "Jack"
    And I enter Person 1 current age as "38"
    And I enter Person 1 planned retirement age as "60"
    And I enter Person 1 annual salary as "$110,000"
    And I enter Person 2 first name as "Jill"
    And I enter Person 2 current age as "41"
    And I enter Person 2 planned retirement age as "60"
    And I enter Person 2 annual salary as "$90,000"
    And I calculate my property owner plan
    And I view the Retirement Income by Source chart
    Then during the transition period (Jill retired, Jack working) a "Jill's super" bar should appear
    And during the transition period a "Jack's salary" bar should appear
    And both bars should be visible at the same age range
