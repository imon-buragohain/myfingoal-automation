Feature: Primary mortgage and offset account calculations

  As a property owner with a home loan
  I want to enter my mortgage details and offset balance accurately
  So that I can see the true interest saving and early payoff benefit

  Background:
    Given I am on the Property Owner planner
    And I select "Individual" as the planning type
    And I enter Person 1 current age as "38"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$120,000"

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @property-owner @mortgage
  Scenario: Entering an interest rate auto-calculates the monthly repayment
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    Then the monthly repayment field should be auto-populated with approximately "$4,497"
    And the repayment field should indicate it was "calculated from rate"

  @smoke @property-owner @mortgage
  Scenario: Offset account balance shows live monthly saving and reduces total interest
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I enter the primary mortgage offset balance as "$80,000"
    And I calculate my property owner plan
    Then the monthly offset saving display should show "$400"
    And the Mortgage and Offset Summary should show a payoff year earlier than "Year 25"
    And the total interest saved via offset should be greater than "$0"

  @smoke @property-owner @mortgage
  Scenario: How we calculated this shows personalised mortgage narrative with correct age
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I enter the primary mortgage offset balance as "$80,000"
    And I calculate my property owner plan
    And I expand "How we calculated this" in the Mortgage and Offset Summary
    Then the narrative should state the primary mortgage payoff year
    And the narrative should state Person 1 age at payoff
    And the narrative should state the monthly interest saving of "$400"

  # ─────────────────────────────────────────────
  # REGRESSION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @property-owner @mortgage
  Scenario: Entering a monthly repayment back-calculates the interest rate
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I clear the monthly repayment field and enter "$4,000"
    Then the annual interest rate field should update to approximately "5.1"

  @regression @property-owner @mortgage
  Scenario: Changing the loan amount with fixed rate recalculates the monthly repayment
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I change the primary mortgage loan amount to "$800,000"
    Then the monthly repayment should update to approximately "$5,139"

  @regression @property-owner @mortgage
  Scenario: Changing months remaining with fixed rate recalculates the monthly repayment
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I change the primary mortgage months remaining to "240"
    Then the monthly repayment field should update to a new positive value

  @regression @property-owner @mortgage
  Scenario Outline: Bidirectional rate and repayment fields stay consistent across loan scenarios
    When I enter the primary mortgage loan amount as "<loan_amount>"
    And I enter the primary mortgage months remaining as "<months>"
    And I enter the primary mortgage annual interest rate as "<rate>"
    Then the monthly repayment should be approximately "<expected_repayment>"

    Examples:
      | loan_amount | months | rate | expected_repayment |
      | $700,000    | 300    | 6.0  | $4,497             |
      | $800,000    | 300    | 6.0  | $5,139             |
      | $500,000    | 300    | 5.5  | $3,069             |
      | $1,000,000  | 360    | 6.5  | $6,321             |

  @regression @property-owner @mortgage
  Scenario: Offset live display updates as balance is typed
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I type "$80,000" into the offset balance field character by character
    Then the live display below the offset field should update and show a positive monthly saving

  @regression @property-owner @mortgage
  Scenario: Mortgage burndown chart shows both declining loan line and rising offset line
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I enter the primary mortgage offset balance as "$80,000"
    And I calculate my property owner plan
    Then the Mortgage Burndown and Offset Growth chart should be visible
    And the chart should display a declining loan balance line
    And the chart should display a rising offset balance line
    And the chart should display a vertical dashed payoff annotation line

  @regression @property-owner @mortgage
  Scenario: How we calculated this narrative contains disclaimer text
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I calculate my property owner plan
    And I expand "How we calculated this" in the Mortgage and Offset Summary
    Then the narrative should contain a disclaimer about fixed rate and consistent repayment assumptions

  @regression @property-owner @mortgage
  Scenario: How we calculated this mentions surplus redirection after mortgage payoff
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I enter the primary mortgage offset balance as "$80,000"
    And I calculate my property owner plan
    And I expand "How we calculated this" in the Mortgage and Offset Summary
    Then the narrative should explain what happens to the freed mortgage payment after payoff

  @regression @property-owner @mortgage
  Scenario Outline: Offset balance produces correct monthly saving for various rates
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "<rate>"
    And I enter the primary mortgage offset balance as "<offset>"
    And I view the offset live display
    Then the monthly offset saving shown should be approximately "<expected_monthly_saving>"

    Examples:
      | rate | offset   | expected_monthly_saving |
      | 6.0  | $80,000  | $400                    |
      | 6.0  | $50,000  | $250                    |
      | 5.5  | $80,000  | $367                    |
      | 6.5  | $100,000 | $542                    |

  @regression @property-owner @mortgage
  Scenario: No mortgage — Mortgage and Offset Summary section hides or shows no mortgage message
    When I enter Person 1 current age as "55"
    And I enter Person 1 planned retirement age as "67"
    And no primary mortgage details are entered
    And I calculate my property owner plan
    Then the Mortgage and Offset Summary section should either be hidden or display "No mortgage entered"
    And the section should not show empty dollar value rows

  @regression @property-owner @mortgage
  Scenario: No mortgage — monthly surplus is positive because no mortgage payment is deducted
    When I enter Person 1 current age as "55"
    And I enter Person 1 planned retirement age as "67"
    And I enter Person 1 current super balance as "$400,000"
    And no primary mortgage details are entered
    And I calculate my property owner plan
    Then the Monthly Surplus KPI card should show a positive dollar amount
