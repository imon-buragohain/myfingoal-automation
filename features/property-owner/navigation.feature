Feature: Property Owner stream navigation and landing page

  As a new or returning user
  I want to find, access, and navigate the Property Owner stream
  So that I can start planning my financial future without confusion

  Background:
    Given I am on the myfingoal landing page

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @property-owner @navigation
  Scenario: Property Owner stream card is visible and navigates to the planner form
    Given the landing page has fully loaded
    When I click the "Start planning" button on the "Property Owner" stream card
    Then the browser URL should contain "/planner/property-owner"
    And the Property Owner form should load within 3 seconds

  @smoke @property-owner @navigation
  Scenario: Demo scenario pre-fills all form fields and shows results immediately
    Given the landing page has fully loaded
    When I click the "View Sarah & James's full financial plan" demo link
    Then the form should show a demo banner indicating this is a demo scenario
    And all form fields should be pre-filled with demo values
    And the results section should be visible without clicking Calculate

  @smoke @property-owner @navigation
  Scenario: Home link in the form sidebar returns user to the landing page
    Given I am on the Property Owner planner
    When I click the "Home" link in the sidebar
    Then the browser URL should be "/"
    And the landing page should display all stream cards

  # ─────────────────────────────────────────────
  # REGRESSION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @property-owner @navigation
  Scenario Outline: Stream card displays required visible elements
    Given the landing page has fully loaded
    Then the "Property Owner" stream card should show a "<element>" that is "<expected_state>"

    Examples:
      | element            | expected_state        |
      | Live badge         | visible               |
      | Start planning CTA | visible and clickable |
      | Description text   | visible               |

  @regression @property-owner @navigation
  Scenario: Property Owner stream card description mentions the expected financial planning topics
    Given the landing page has fully loaded
    Then the "Property Owner" stream card description text should mention at least two of the following topics:
      | topic             |
      | offset account    |
      | super             |
      | negative gearing  |
      | retirement income |

  @regression @property-owner @navigation
  Scenario: Demo banner can be dismissed without affecting inputs or results
    Given I am on the Property Owner planner in demo mode
    When I dismiss the demo banner
    Then the demo banner should no longer be visible
    And the form fields should still contain the demo values
    And the results section should still be visible

  @regression @property-owner @navigation
  Scenario: User can edit a pre-filled demo value and recalculate
    Given I am on the Property Owner planner in demo mode
    When I change Person 1 salary to "$100,000"
    And I calculate my property owner plan
    Then the results section should update to reflect the new inputs
    And the demo banner should no longer block interaction
