Feature: Savings allocation phases and investment options

  As a property owner choosing how to grow my wealth
  I want to allocate my monthly surplus across offset and investment options
  So that the calculation engine reflects my actual savings strategy

  Background:
    Given I am on the Property Owner planner
    And I select "Individual" as the planning type
    And I enter Person 1 current age as "40"
    And I enter Person 1 planned retirement age as "65"
    And I enter Person 1 annual salary as "$120,000"

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @property-owner @savings
  Scenario: Primary mortgage only shows exactly two savings allocation phases
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And the Investment Property section is disabled
    And I view the Savings Allocation section
    Then exactly "2" savings allocation phase panels should be visible
    And the panels should be labelled "While paying off mortgage" and "After mortgage paid off"

  @smoke @property-owner @savings
  Scenario: Primary plus IP with P&I loan shows exactly three savings allocation phases
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I enable the Investment Property section
    And I enter the IP loan amount as "$1,100,000"
    And I enter the IP annual interest rate as "6.1"
    And I enter the IP months remaining as "340"
    And I select "Principal & Interest" as the IP loan type
    And I view the Savings Allocation section
    Then exactly "3" savings allocation phase panels should be visible

  @smoke @property-owner @savings
  Scenario: Allocation reaching 100 percent shows green tick confirmation
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I allocate "60" percent to "Offset Account" in Phase 1
    And I allocate "40" percent to "ASX 200" in Phase 1
    Then a green "100% allocated" confirmation should be visible in Phase 1

  # ─────────────────────────────────────────────
  # REGRESSION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @property-owner @savings
  Scenario: Primary plus IP with IO loan shows exactly two savings allocation phases
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I enable the Investment Property section
    And I enter the IP loan amount as "$1,100,000"
    And I enter the IP annual interest rate as "6.1"
    And I enter the IP months remaining as "340"
    And I select "Interest Only" as the IP loan type
    And I view the Savings Allocation section
    Then exactly "2" savings allocation phase panels should be visible
    And the IP offset phase should not be present

  @regression @property-owner @savings
  Scenario: No mortgage and no IP shows exactly one savings allocation phase
    When no primary mortgage details are entered
    And the Investment Property section is disabled
    And I view the Savings Allocation section
    Then exactly "1" savings allocation phase panel should be visible

  @regression @property-owner @savings
  Scenario: Under-allocated phase shows a warning with the remaining percentage
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I allocate "60" percent to "Offset Account" in Phase 1
    Then a warning message should show the remaining percentage to allocate in Phase 1
    And the warning should indicate "40%" remains unallocated

  @regression @property-owner @savings
  Scenario: Phase 1 includes an Offset Account option when a primary mortgage is active
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I view the Savings Allocation section
    Then a blue "Offset Account" option should be present in Phase 1

  @regression @property-owner @savings
  Scenario Outline: All investment options are available in every investment phase
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I view phase "<phase_number>" in the Savings Allocation section
    Then the investment option "<investment_option>" should be listed

    Examples:
      | phase_number | investment_option |
      | 2            | ASX 200           |
      | 2            | S&P 500           |
      | 2            | Crypto            |
      | 2            | Savings Account   |

  @regression @property-owner @savings
  Scenario: Investment portfolio at retirement section is visible when investment allocation is above zero
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I allocate "50" percent to "Offset Account" in Phase 1
    And I allocate "25" percent to "ASX 200" in Phase 1
    And I allocate "25" percent to "S&P 500" in Phase 1
    And I calculate my property owner plan
    Then the Investment Portfolio at Retirement section should be visible
    And an ASX 200 card should be visible
    And an S&P 500 card should be visible
    And a Total Portfolio card should be visible
    And the CGT amber banner should show an estimated CGT amount

  @regression @property-owner @savings
  Scenario: Crypto card only appears when a Crypto allocation is entered
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I allocate "50" percent to "Offset Account" in Phase 1
    And I allocate "50" percent to "ASX 200" in Phase 1
    And I calculate my property owner plan
    Then no Crypto card should be visible in the Investment Portfolio at Retirement section

  @regression @property-owner @savings
  Scenario: How we calculated this for investment portfolio shows actual post-retirement return rate
    When I enter the primary mortgage loan amount as "$700,000"
    And I enter the primary mortgage months remaining as "300"
    And I enter the primary mortgage annual interest rate as "6.0"
    And I set the post-retirement blended return assumption to "7.0"
    And I allocate "50" percent to "Offset Account" in Phase 1
    And I allocate "50" percent to "ASX 200" in Phase 1
    And I calculate my property owner plan
    And I expand "How we calculated this" in the Investment Portfolio section
    Then the explanation should state the post-retirement blended return rate
    And the rate shown should not be hardcoded — it should reflect the assumptions entered

  @regression @property-owner @savings
  Scenario: Homeowner with no mortgage can calculate with a single invest-only phase
    When I enter Person 1 current super balance as "$400,000"
    And no primary mortgage details are entered
    And the Investment Property section is disabled
    And I calculate my property owner plan
    Then the Results page should display without error
    And the Savings Allocation section should show exactly "1" phase panel
    And the Retirement Lifestyle Simulator should show an optimal monthly income
