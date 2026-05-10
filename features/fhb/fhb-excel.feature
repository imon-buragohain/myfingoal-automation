# AUTO-GENERATED — do not edit manually
# Source: fixtures/fhb-test-cases.xlsx
# Generated: 2026-05-09T04:30:36.613Z
# To regenerate: node scripts/generate-excel-feature.js

Feature: FHB complete regression suite — Excel driven
  All 43 test cases loaded directly from the Excel test case register.
  To add or modify tests, update fixtures/fhb-test-cases.xlsx and regenerate.

  Background:
    Given I am on the First Home Buyer planner

  @excel @fhb @regression
  Scenario Outline: FHB test case <test_case> — <notes>
    Given I am buying as a "<family_type>" "<residency>" in "<state>"
    And I enter a salary of "<salary>"
    And the property is a "<property_type>" valued at "<price>"
    And I enter a contract month of "<contract_month>"
    When I calculate my first home buyer plan
    Then the stamp duty payable should be "<expected_stamp_duty>"
    And the First Home Owner Grant should be "<expected_fhog>"
    And Help to Buy should be "<expected_htb>"

    Examples:
      | test_case | family_type | residency | state | salary | property_type | price | contract_month | expected_stamp_duty | expected_fhog | expected_htb | notes |
      | TC1 | Couple | Citizen | QLD | $165000 | New | $750000 | 2026-06 | $0 | $30000 | not eligible | New ≤$750k, before FHOG reversion |
      | TC2 | Couple | Citizen | QLD | $165000 | New | $750000 | 2026-08 | $0 | $15000 | not eligible | New ≤$750k, after FHOG reversion → $15k |
      | TC3 | Couple | Citizen | QLD | $165000 | New | $900000 | 2026-04 | $0 | $0 | not eligible | New >$750k, no FHOG, still no stamp duty |
      | TC4 | Individual | Citizen | QLD | $90000 | Established | $650000 | 2026-04 | $0 | $0 | eligible | Established ≤$700k, full exemption |
      | TC5 | Couple | Citizen | QLD | $140000 | Established | $750000 | 2026-04 | >$0 | $0 | eligible | Established $700k–$800k, partial |
      | TC6 | Couple | Citizen | QLD | $140000 | Established | $850000 | 2026-04 | >$0 | $0 | eligible | Established >$800k, full duty |
      | TC7 | Couple | Citizen | QLD | $180000 | New | $750000 | 2026-04 | $0 | $30000 | not eligible | Income >$160k, HTB ineligible |
      | TC8 | Individual | PR | QLD | $80000 | New | $600000 | 2026-04 | $0 | $30000 | not eligible | PR: eligible FHBG, not HTB |
      | TC11 | Couple | Citizen | NSW | $150000 | New | $780000 | 2026-04 | $0 | $10000 | eligible | New ≤$800k, full exemption |
      | TC12 | Individual | Citizen | NSW | $80000 | Established | $750000 | 2026-04 | $0 | $0 | eligible | Established ≤$800k, full exemption |
      | TC13 | Couple | Citizen | NSW | $150000 | New | $900000 | 2026-04 | >$0 | $10000 | eligible | $800k–$1M, partial concession |
      | TC14 | Couple | Citizen | NSW | $150000 | New | $1100000 | 2026-04 | >$0 | $10000 | eligible | >$1M, full duty |
      | TC15 | Couple | Citizen | NSW | $140000 | New | $1400000 | 2026-04 | >$0 | $10000 | not eligible | Near HTB Sydney cap ($1.3M) |
      | TC16 | Individual | PR | NSW | $75000 | Established | $700000 | 2026-04 | $0 | $0 | not eligible | PR: full exemption, no HTB |
      | TC18 | Individual | Citizen | VIC | $70000 | New | $580000 | 2026-04 | $0 | $10000 | eligible | New ≤$600k, full exemption |
      | TC19 | Couple | Citizen | VIC | $140000 | Established | $590000 | 2026-04 | $0 | $0 | eligible | Established ≤$600k, full exemption |
      | TC20 | Couple | Citizen | VIC | $140000 | New | $680000 | 2026-04 | >$0 | $10000 | eligible | $600k–$750k, partial concession |
      | TC21 | Couple | Citizen | VIC | $140000 | Established | $800000 | 2026-04 | >$0 | $0 | eligible | Established >$750k, full duty |
      | TC22 | Individual | Citizen | VIC | $80000 | New | $780000 | 2026-04 | >$0 | $0 | eligible | New >$750k, no FHOG, no exemption |
      | TC23 | Individual | PR | VIC | $70000 | New | $580000 | 2026-04 | $0 | $10000 | not eligible | PR: full exemption, no HTB |
      | TC24 | Couple | Citizen | SA | $140000 | New | $1200000 | 2026-04 | $0 | $0 | not eligible | New, no price cap, full exemption |
      | TC25 | Individual | Citizen | SA | $70000 | Established | $600000 | 2026-04 | >$0 | $0 | eligible | Established, no stamp duty relief |
      | TC26 | Individual | Citizen | SA | $70000 | New | $550000 | 2026-04 | $0 | $15000 | eligible | New ≤$575k, FHOG $15k |
      | TC27 | Couple | Citizen | SA | $140000 | New | $650000 | 2026-04 | $0 | $0 | eligible | New >$575k, no FHOG |
      | TC29 | Individual | PR | SA | $70000 | New | $600000 | 2026-04 | $0 | $0 | not eligible | PR: full exemption, no HTB |
      | TC30 | Individual | Citizen | WA | $70000 | Established | $480000 | 2026-04 | $0 | $0 | not eligible | Established ≤$500k, full exemption |
      | TC31 | Couple | Citizen | WA | $130000 | New | $550000 | 2026-04 | >$0 | $10000 | not eligible | $500k–$600k, partial concession |
      | TC32 | Couple | Citizen | WA | $130000 | Established | $700000 | 2026-04 | >$0 | $0 | not eligible | >$600k, full duty |
      | TC34 | Individual | PR | WA | $70000 | Established | $450000 | 2026-04 | $0 | $0 | not eligible | PR: full exemption (WA), HTB N/A |
      | TC35 | Couple | Citizen | TAS | $140000 | Established | $700000 | 2026-04 | $0 | $0 | not eligible | Established ≤$750k before expiry |
      | TC36 | Couple | Citizen | TAS | $140000 | Established | $700000 | 2026-09 | >$0 | $0 | not eligible | After Jun 2026 expiry, full duty |
      | TC37 | Individual | Citizen | TAS | $70000 | New | $600000 | 2026-04 | $0 | $30000 | eligible | New home, FHOG $30k, before expiry |
      | TC38 | Couple | Citizen | TAS | $140000 | New | $800000 | 2026-04 | >$0 | $0 | not eligible | >$750k, no exemption, no FHOG |
      | TC39 | Individual | PR | TAS | $70000 | New | $600000 | 2026-04 | $0 | $30000 | not eligible | PR: exemption applies, no HTB |
      | TC40 | Couple | Citizen | ACT | $150000 | New | $950000 | 2026-04 | $0 | $0 | eligible | ≤$1.02M, income ok, full exemption |
      | TC41 | Individual | Citizen | ACT | $185000 | Established | $800000 | 2026-04 | >$0 | $0 | not eligible | Income test failed (>$170k single) |
      | TC42 | Couple | Citizen | ACT | $250000 | New | $900000 | 2026-04 | >$0 | $0 | not eligible | Income test failed (>$227k couple) |
      | TC43 | Couple | Citizen | ACT | $150000 | New | $1100000 | 2026-04 | >$0 | $0 | not eligible | >$1.02M, no exemption |
      | TC44 | Individual | Citizen | ACT | $80000 | New | $700000 | 2026-04 | $0 | $0 | eligible | ACT: no FHOG regardless |
      | TC45 | Individual | PR | ACT | $70000 | New | $700000 | 2026-04 | $0 | $0 | not eligible | PR: income ok, exempt, no HTB |
      | TC46 | Individual | Citizen | NT | $80000 | New | $700000 | 2026-04 | $0 | $50000 | eligible | New home, H&L Package, $50k grant |
      | TC47 | Couple | Citizen | NT | $140000 | Established | $600000 | 2026-04 | >$0 | $0 | eligible | Established, no relief, no grant |
      | TC48 | Individual | PR | NT | $70000 | New | $600000 | 2026-04 | $0 | $50000 | not eligible | PR: new home exemption, no HTB |
