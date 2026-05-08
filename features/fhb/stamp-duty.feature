Feature: Stamp duty calculation for Queensland first home buyers

  As a first home buyer in Queensland
  I want to know how much stamp duty I will pay
  So that I can accurately plan my upfront costs

  Background:
    Given I am on the First Home Buyer planner
    And I am an Australian Citizen planning for just me
    And I enter a default salary of "$80,000"
    And I enter a contract month of "2025-08"

  @smoke @fhb
  Scenario: New build under $750k receives full stamp duty exemption
    Given I am buying in "QLD"
    And the property is a "New Build" valued at "$650,000"
    When I calculate my first home buyer plan
    Then the stamp duty payable should be "$0"
    And the stamp duty saving should be greater than "$0"

 @smoke @fhb
Scenario: Established home over $700k receives stamp duty charge
  Given I am buying in "QLD"
  And the property is a "Established" valued at "$800,000"
  When I calculate my first home buyer plan
  Then the stamp duty payable should be ">$0"

  @regression @fhb
  Scenario Outline: Stamp duty exemption boundary conditions
    Given I am buying in "<state>"
    And the property is a "<property_type>" valued at "<price>"
    When I calculate my first home buyer plan
    Then the stamp duty payable should be "<expected_duty>"

Examples:
  | state | property_type | price      | expected_duty |
  | QLD   | New Build     | $749,000   | $0            |
  | QLD   | New Build     | $800,000   | $0            |
  | QLD   | Established   | $699,000   | $0            |
  | QLD   | Established   | $700,001   | >$0           |
  | NSW   | New Build     | $800,000   | $0            |
  | NSW   | New Build     | $1,000,001 | >$0           |