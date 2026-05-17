Feature: Children education costs and novated lease tax benefits

  As a parent and property owner
  I want to account for education costs and vehicle leasing strategies
  So that my financial plan reflects my true lifestyle and tax situation

  Background:
    Given I am on the Property Owner planner
    And I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$120,000"

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @property-owner @children
  Scenario: Enter children's education costs and see monthly impact
    When I expand the Children & Education section
    And I select "1" child
    And I enter Child 1 current age as "12"
    And I select "High school" as the child stage
    And I enter annual school fees as "$5,000"
    And I enter annual extras as "$4,000"
    And I enter university fund as "$20,000"
    Then a green display should show "Monthly school cost: $750 / month"
    And the university fund of "$20,000" should be noted for withdrawal at end of Year 12

  @smoke @property-owner @children
  Scenario: EV novated lease shows pre-tax treatment and tax saving
    When I expand the Expenses section
    And I expand the Novated Lease Details section
    And I select "EV" as the vehicle type
    Then helper text should state "FBT exempt — full lease cost is pre-tax"
    And I enter annual lease cost as "$15,000"
    When I calculate my property owner plan
    Then the results should reflect the pre-tax treatment of the lease
    And the Monthly Surplus KPI should be higher than if the lease were post-tax

  # ─────────────────────────────────────────────
  # REGRESSION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @property-owner @children
  Scenario: Children section allows selecting 0 to 4 children
    When I expand the Children & Education section
    Then a dropdown should allow selecting "0" children
    And a dropdown should allow selecting "1" child
    And a dropdown should allow selecting "2" children
    And a dropdown should allow selecting "3" children
    And a dropdown should allow selecting "4" children

  @regression @property-owner @children
  Scenario: Child age field accepts 0 to 17
    When I expand the Children & Education section
    And I select "1" child
    Then the child age field should accept "0"
    And the child age field should accept "17"

  @regression @property-owner @children
  Scenario: Child stage dropdown includes all education levels
    When I expand the Children & Education section
    And I select "1" child
    Then the stage dropdown should show "Childcare"
    And the stage dropdown should show "Primary school (Year 1-6)"
    And the stage dropdown should show "High school (Year 7-12)"

  @regression @property-owner @children
  Scenario: Annual school fees and extras calculate monthly display
    When I expand the Children & Education section
    And I select "1" child
    And I enter annual school fees as "$5,000"
    And I enter annual extras as "$4,000"
    Then the monthly school cost display should show "$750 / month"
    And the calculation should be "(5000 + 4000) / 12"

  @regression @property-owner @children
  Scenario: Multiple children costs are summed in monthly surplus
    When I expand the Children & Education section
    And I select "2" children
    And I enter Child 1 annual school fees as "$4,000"
    And I enter Child 1 annual extras as "$2,000"
    And I enter Child 2 annual school fees as "$6,000"
    And I enter Child 2 annual extras as "$3,000"
    And I calculate my property owner plan
    Then the Monthly Surplus KPI should deduct "$750 + $750 = $1,500 / month"

  @regression @property-owner @children
  Scenario: University fund is withdrawn from offset at end of Year 12
    When I expand the Children & Education section
    And I select "1" child
    And I enter Child 1 current age as "12"
    And I select "High school" as the child stage
    And I enter university fund as "$30,000"
    And I enter the primary mortgage offset balance as "$100,000"
    And I calculate my property owner plan
    Then the Mortgage Burndown and Offset Growth chart should show a dip at the end of Year 12
    And the offset balance should decrease by approximately "$30,000"

  @regression @property-owner @children
  Scenario: Non-EV novated lease shows Employee Contribution Method treatment
    When I expand the Novated Lease Details section
    And I select "Non-EV" as the vehicle type
    Then helper text should describe the Employee Contribution Method (ECM)

  @regression @property-owner @children
  Scenario: EV novated lease pre-tax treatment reduces take-home deduction
    When I expand the Novated Lease Details section
    And I select "EV" as the vehicle type
    And I enter annual lease cost as "$15,000"
    And I calculate my property owner plan with a salary of "$120,000"
    Then the Monthly Surplus should show post-tax cost of the lease
    And the post-tax cost should be approximately "$844 / month" not "$1,250 / month"

  @regression @property-owner @children
  Scenario: KPI cards reflect children and lease expenses
    When I expand the Children & Education section
    And I select "1" child
    And I enter Child 1 current age as "12"
    And I enter annual school fees as "$5,000"
    And I enter annual extras as "$4,000"
    And I expand the Novated Lease Details section
    And I select "EV" as the vehicle type
    And I enter annual lease cost as "$15,000"
    And I calculate my property owner plan
    Then the Monthly Surplus KPI should reflect both the school costs and lease costs
