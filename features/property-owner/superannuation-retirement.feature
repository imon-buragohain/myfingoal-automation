Feature: Superannuation projections and retirement income calculations

  As a property owner planning for retirement
  I want to see accurate super projections and retirement income
  So that I can understand my financial security in retirement

  Background:
    Given I am on the Property Owner planner
    And I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$120,000"

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @property-owner @super
  Scenario: Super balance projects to retirement with correct deductions
    When I enter Person 1 current super balance as "$150,000"
    And I enter Person 1 super rate as "12.0"
    And I calculate my property owner plan
    Then the Superannuation Summary section should be visible
    And a row should show "Person 1 super at retirement" with a dollar value
    And the super balance should be greater than "$150,000"
    And a balance note should state "in future (nominal) dollars"

  @smoke @property-owner @super
  Scenario: Optimal retirement income is calculated and displayed
    When I enter Person 1 current super balance as "$150,000"
    And I enter Person 1 super rate as "12.0"
    And I enter the primary mortgage loan amount as "$0"
    And I enter the primary mortgage months remaining as "0"
    And I calculate my property owner plan
    Then the Retirement Lifestyle Simulator section should be visible
    And an optimal monthly income amount should be displayed
    And a status message should state "Balanced — This is your optimised spending level"
    And the Monthly Retirement Income KPI card should match the optimal slider value

  @smoke @property-owner @super
  Scenario: Combined super balance shown for couple scenarios
    When I select "Couple" as the planning type
    And I enter Person 1 first name as "Jack"
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$110,000"
    And I enter Person 1 current super balance as "$150,000"
    And I enter Person 2 first name as "Jill"
    And I enter Person 2 current age as "38"
    And I enter Person 2 planned retirement age as "65"
    And I enter Person 2 annual salary as "$100,000"
    And I enter Person 2 current super balance as "$120,000"
    And I calculate my property owner plan
    Then the Superannuation Summary should show "Jack super at retirement"
    And the Superannuation Summary should show "Jill super at retirement"
    And a "Combined super balance" row should equal the sum of both

  # ─────────────────────────────────────────────
  # REGRESSION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @property-owner @super
  Scenario: Annual income rows show 4% and 5% drawdown calculations
    When I enter Person 1 current super balance as "$1,000,000"
    And I enter Person 1 super rate as "12.0"
    And I calculate my property owner plan
    And I view the Superannuation Summary
    Then a row should show income at "4% drawdown"
    And a row should show income at "5% drawdown"
    And the 5% drawdown income should be higher than 4% drawdown

  @regression @property-owner @super
  Scenario: How we calculated this shows admin fees and insurance details
    When I enter Person 1 current super balance as "$150,000"
    And I enter Person 1 super rate as "12.0"
    And I calculate my property owner plan
    And I expand "How we calculated this" in the Superannuation Summary
    Then the explanation should show admin fees
    And the explanation should show life insurance details
    And the explanation should show the return rate

  @regression @property-owner @super
  Scenario: How we calculated this shows the actual return rate from assumptions
    When I enter Person 1 current super balance as "$150,000"
    And I enter Person 1 super rate as "12.0"
    And I set the super annual gross return assumption to "8.5"
    And I calculate my property owner plan
    And I expand "How we calculated this" in the Superannuation Summary
    Then the explanation should show "8.5% gross annual return"
    And the explanation should not show a different hardcoded value

  @regression @property-owner @super
  Scenario: Lifestyle slider updates retirement income chart in real time
    When I enter Person 1 current super balance as "$200,000"
    And I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I calculate my property owner plan
    And I note the optimal monthly income value
    When I drag the Retirement Lifestyle Simulator slider down by "25%"
    Then the monthly income display should update
    And the Retirement Income by Source chart should update
    And the Balance Projection chart should update
    And the "Super runs out" dashed line should move

  @regression @property-owner @super
  Scenario: Lifestyle slider shows increasing estate value when below optimal
    When I enter Person 1 current super balance as "$200,000"
    And I enter the primary mortgage loan amount as "$0"
    And I calculate my property owner plan
    And I note the optimal estate value
    When I drag the Retirement Lifestyle Simulator slider down by "25%"
    Then the estate value should increase
    And no discontinuity or cliff jump should occur in the balance chart

  @regression @property-owner @super
  Scenario: Lifestyle slider status shows "Legacy mode" when below optimal
    When I enter Person 1 current super balance as "$200,000"
    And I calculate my property owner plan
    When I drag the Retirement Lifestyle Simulator slider below the optimal value
    Then the status message should change to "Legacy mode"
    And an estate value should be displayed

  @regression @property-owner @super
  Scenario: Lifestyle slider status shows depletion age when above optimal
    When I enter Person 1 current super balance as "$200,000"
    And I calculate my property owner plan
    When I drag the Retirement Lifestyle Simulator slider above the optimal value
    Then the status message should show "Assets deplete at age" followed by a number

  @regression @property-owner @super
  Scenario: Couple retirement shows correct partner names and income sources
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
    And I calculate my property owner plan
    And I view the Retirement Income by Source chart
    Then during transition years the chart should show "Jill's super" bar
    And during transition years the chart should show "Jack's salary" bar
    And the legend should not contain "P1", "P2", or "Partner" labels

  @regression @property-owner @super
  Scenario: Retirement Income Breakdown shows first retiree's super drawdown row
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
    And I view the Retirement Income Breakdown section
    Then a row should show "Jill super drawdown (year 1)"
    And the value should be a positive dollar amount

  @regression @property-owner @super
  Scenario: Retirement Income Breakdown shows working partner salary during transition
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
    And I view the Retirement Income Breakdown section
    Then a row should show "Jack salary (transition — still working at Jill's retirement)"
    And the value should be a positive monthly amount

  @regression @property-owner @super
  Scenario: Age Pension commences at 67 with zero value at earlier retirement age
    When I enter Person 1 current age as "50"
    And I enter Person 1 planned retirement age as "60"
    And I enter Person 1 annual salary as "$120,000"
    And I enter Person 1 current super balance as "$200,000"
    And I calculate my property owner plan
    And I view the Retirement Income Breakdown section
    Then a row should show "Age pension — commences age 67"
    And at retirement age 60 the pension value should show "$0 at retirement"

  @regression @property-owner @super
  Scenario: Age Pension bars appear on chart from age 67 onwards
    When I enter Person 1 current age as "50"
    And I enter Person 1 planned retirement age as "60"
    And I enter Person 1 annual salary as "$120,000"
    And I enter Person 1 current super balance as "$200,000"
    And I calculate my property owner plan
    And I view the Retirement Income by Source chart
    Then blue Age Pension bars should not appear before age 67
    And blue Age Pension bars should appear from age 67 onwards
    And the bars should grow taller in later retirement years as assets deplete

  @regression @property-owner @super
  Scenario: High income triggers Division 293 super tax
    When I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$280,000"
    And I enter Person 1 current super balance as "$150,000"
    And I calculate my property owner plan
    And I expand "How we calculated this" in the Superannuation Summary
    Then the explanation should mention "Division 293 tax"
    Or a Division 293 note should appear

  @regression @property-owner @super
  Scenario: Division 293 no longer applies when salary drops below threshold
    When I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$280,000"
    And I calculate my property owner plan
    And Division 293 tax is mentioned in results
    When I change Person 1 annual salary to "$200,000"
    And I calculate my property owner plan
    Then no Division 293 notation should appear in results

  @regression @property-owner @super
  Scenario: Division 293 reduces super balance at retirement compared to no tax
    When I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$280,000"
    And I enter Person 1 current super balance as "$150,000"
    And I calculate my property owner plan
    And I note the super balance at retirement
    When I change Person 1 annual salary to "$200,000"
    And I calculate my property owner plan
    Then the super balance should be higher than the Division 293 scenario

    @regression @property-owner @super
  Scenario: High income of 280000 triggers Division 293 super tax notation in results
    Given I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$280,000"
    And I set the "Salary includes Superannuation" toggle to "on"
    And I enter Person 1 current super balance as "$200,000"
    When I calculate my property owner plan
    And I expand "How we calculated this" in the Superannuation Summary
    Then the explanation should mention "Division 293"

  @regression @property-owner @super
  Scenario: Income below Division 293 threshold of 250000 does not show Division 293 notation
    Given I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$200,000"
    And I set the "Salary includes Superannuation" toggle to "on"
    And I enter Person 1 current super balance as "$200,000"
    When I calculate my property owner plan
    And I expand "How we calculated this" in the Superannuation Summary
    Then the explanation should not mention "Division 293"

  @regression @property-owner @super
  Scenario Outline: Division 293 threshold boundary applies at the correct income level
    Given I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "<salary>"
    And I set the "Salary includes Superannuation" toggle to "on"
    And I enter Person 1 current super balance as "$200,000"
    When I calculate my property owner plan
    And I expand "How we calculated this" in the Superannuation Summary
    Then the Division 293 notation should be "<expected_div293_visible>"

    Examples:
      | salary   | expected_div293_visible |
      | $200,000 | not visible             |
      | $280,000 | visible                 |

