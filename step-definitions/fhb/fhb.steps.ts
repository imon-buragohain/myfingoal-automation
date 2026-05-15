import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import { ICustomWorld } from '../../support/world';
import { FHBPage } from '../../pages/FHBPage';

let fhbPage: FHBPage;

// ═══════════════════════════════════════════════════════════════════
// NAVIGATION
// Used by: stamp-duty.feature, fhog.feature, help-to-buy.feature,
//          fhb-excel.feature (via Background in every feature)
// ═══════════════════════════════════════════════════════════════════

Given('I am on the First Home Buyer planner',
  async function (this: ICustomWorld) {
    await this.page.goto('/planner/fhb', {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });
    await this.page.waitForSelector(
      'button:has-text("Just me")',
      { timeout: 30000 }
    );
    console.log('FHB form loaded and ready');
    fhbPage = new FHBPage(this.page);
  }
);

// ═══════════════════════════════════════════════════════════════════
// SECTION 1 — WHO IS THIS FOR
// ═══════════════════════════════════════════════════════════════════

// Used by: stamp-duty.feature Background
// Sets planning type to 'Just me' and residency to Australian Citizen
Given('I am an Australian Citizen planning for just me',
  async function (this: ICustomWorld) {
    await fhbPage.selectPlanningFor('Just me');
    await fhbPage.selectResidency('Australian Citizen');
  }
);

// Used by: fhog.feature, help-to-buy.feature, fhb-excel.feature
// Accepts family type (Individual/Couple) and residency (Citizen/PR)
// and state — all three set in one step for Excel-driven scenarios
Given('I am buying as a {string} {string} in {string}',
  async function (
    this: ICustomWorld,
    familyType: string,
    residency: string,
    state: string
  ) {
    fhbPage = new FHBPage(this.page);
    const planningFor = familyType.toLowerCase() === 'couple'
      ? 'Couple' : 'Just me';
    const residencyType = residency === 'PR'
      ? 'Permanent Resident' : 'Australian Citizen';
    await fhbPage.selectPlanningFor(planningFor);
    await fhbPage.selectResidency(residencyType);
    await fhbPage.selectState(state);
  }
);

// Used by: stamp-duty.feature
// Sets state only — used when planning type and residency
// are already set in a prior Background step
Given('I am buying in {string}',
  async function (this: ICustomWorld, state: string) {
    await fhbPage.selectState(state);
  }
);

// ═══════════════════════════════════════════════════════════════════
// SECTION 2 — INCOME
// ═══════════════════════════════════════════════════════════════════

// Used by: stamp-duty.feature Background
// Enters a fixed default salary for scenarios where salary is
// irrelevant to the assertion (e.g. stamp duty boundary tests)
Given('I enter a default salary of {string}',
  async function (this: ICustomWorld, salaryString: string) {
    const salary = FHBPage.parsePrice(salaryString);
    await fhbPage.enterSingleSalary(salary);
  }
);

// Used by: fhog.feature, help-to-buy.feature, fhb-excel.feature
// Smart salary entry — auto-detects couple vs individual mode
// by checking whether 'Person 1' label is present in the DOM.
// For couples: splits salary equally between both partners.
Given('I enter a salary of {string}',
  async function (this: ICustomWorld, salaryString: string) {
    const salary = FHBPage.parsePrice(salaryString);
    const isCouple = await this.page.locator('text=Person 1').count() > 0;
    if (isCouple) {
      const each = Math.floor(salary / 2);
      await fhbPage.enterCoupleSalaries(each, each);
    } else {
      await fhbPage.enterSingleSalary(salary);
    }
  }
);

// Used by: fhog.feature smoke scenarios (explicit couple salary)
// Use when you need to state the combined salary clearly in the
// scenario for readability, rather than relying on auto-detection
Given('I enter a combined salary of {string}',
  async function (this: ICustomWorld, salaryString: string) {
    const total = FHBPage.parsePrice(salaryString);
    const each = Math.floor(total / 2);
    await fhbPage.enterCoupleSalaries(each, each);
  }
);

// ═══════════════════════════════════════════════════════════════════
// SECTION 3 — PROPERTY TARGET
// ═══════════════════════════════════════════════════════════════════

// Used by: stamp-duty.feature, fhog.feature, help-to-buy.feature,
//          fhb-excel.feature
// Selects property type (New Build or Established) and enters price.
// 'New' or 'new' in the parameter maps to 'New Build' button.
// Any other value maps to 'Established' button.
Given('the property is a {string} valued at {string}',
  async function (
    this: ICustomWorld,
    propertyType: string,
    priceString: string
  ) {
    const price = FHBPage.parsePrice(priceString);
    const type = propertyType.toLowerCase().includes('new')
      ? 'New Build'
      : 'Established';
    await fhbPage.selectPropertyType(type);
    await fhbPage.enterPropertyPrice(price);
  }
);

// Used by: stamp-duty.feature Background, fhog.feature,
//          help-to-buy.feature, fhb-excel.feature
// Enters the contract month in YYYY-MM format.
// Determines which FHOG amount applies (QLD reversion 30 June 2026)
// and which stamp duty rules apply (TAS concession expiry).
Given('I enter a contract month of {string}',
  async function (this: ICustomWorld, yearMonth: string) {
    await fhbPage.enterContractMonth(yearMonth);
  }
);

// ═══════════════════════════════════════════════════════════════════
// WHEN — CALCULATE
// Used by: all four FHB feature files
// ═══════════════════════════════════════════════════════════════════

When('I calculate my first home buyer plan',
  async function (this: ICustomWorld) {
    await fhbPage.calculate();
  }
);

// ═══════════════════════════════════════════════════════════════════
// THEN — STAMP DUTY ASSERTIONS
// Used by: stamp-duty.feature, fhb-excel.feature
// ═══════════════════════════════════════════════════════════════════

// Asserts the stamp duty amount in the Upfront Costs section.
// Three cases:
//   '$0'  — asserts zero AND checks 'Full exemption' badge is present
//   '>$0' — asserts any positive amount (partial or full duty)
//   '$X'  — asserts exact dollar amount
Then('the stamp duty payable should be {string}',
  async function (this: ICustomWorld, expectedValue: string) {
    if (expectedValue === '$0') {
      const amount = await fhbPage.getStampDutyAmount();
      expect(amount).toBe(0);
      const hasExemption = await fhbPage.hasFullExemption();
      expect(hasExemption).toBe(true);
    } else if (expectedValue === '>$0') {
      const amount = await fhbPage.getStampDutyAmount();
      expect(amount).toBeGreaterThan(0);
    } else {
      const expected = FHBPage.parsePrice(expectedValue);
      const amount = await fhbPage.getStampDutyAmount();
      expect(amount).toBe(expected);
    }
  }
);

// Used by: stamp-duty.feature smoke test
// Asserts that the stamp duty saving (vs standard duty) is positive.
// The saving appears in the Deposit Breakdown section.
Then('the stamp duty saving should be greater than {string}',
  async function (this: ICustomWorld, expectedValue: string) {
    const expected = FHBPage.parsePrice(expectedValue);
    const saving = await fhbPage.getStampDutySaving();
    expect(saving).toBeGreaterThan(expected);
  }
);

// ═══════════════════════════════════════════════════════════════════
// THEN — FIRST HOME OWNER GRANT ASSERTIONS
// Used by: fhog.feature, fhb-excel.feature
// ═══════════════════════════════════════════════════════════════════

// Asserts the FHOG amount displayed in the Upfront Costs section.
// Amount is shown as '− $30,000' — the parseCurrency method
// handles the Unicode minus character (U+2212) correctly.
// Pass '$0' to assert grant is not available.
Then('the First Home Owner Grant should be {string}',
  async function (this: ICustomWorld, expectedValue: string) {
    const expected = FHBPage.parsePrice(expectedValue);
    const actual = await fhbPage.getFHOGAmount();
    console.log(`FHOG expected: $${expected}, actual: $${actual}`);
    expect(actual).toBe(expected);
  }
);

// Used by: fhog.feature
// Alternative assertion when you want to explicitly state
// ineligibility in the scenario rather than asserting '$0'
Then('the First Home Owner Grant should not be available',
  async function (this: ICustomWorld) {
    const eligible = await fhbPage.isFHOGEligible();
    expect(eligible).toBe(false);
  }
);

// ═══════════════════════════════════════════════════════════════════
// THEN — HELP TO BUY ASSERTIONS
// Used by: help-to-buy.feature, fhb-excel.feature
// ═══════════════════════════════════════════════════════════════════

// Asserts Help to Buy eligibility badge in the Entry Strategies section.
// The HTB card is the third card — Codegen confirmed badge is nth(2).
// Expected values: 'eligible' or 'not eligible' (lowercase)
Then('Help to Buy should be {string}',
  async function (this: ICustomWorld, expectedStatus: string) {
    const actual = await fhbPage.getHelpToBuyStatus();
    console.log(`HTB expected: ${expectedStatus}, actual: ${actual}`);
    expect(actual).toBe(expectedStatus.toLowerCase());
  }
);
