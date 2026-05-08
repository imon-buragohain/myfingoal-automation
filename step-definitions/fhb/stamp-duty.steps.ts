import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import { ICustomWorld } from '../../support/world';
import { FHBPage } from '../../pages/FHBPage';

let fhbPage: FHBPage;

// -------------------------------------------
// Navigation
// -------------------------------------------

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
    console.log(`FHB form loaded and ready`);
    fhbPage = new FHBPage(this.page);
  }
);

// -------------------------------------------
// Background steps
// -------------------------------------------

Given('I am an Australian Citizen planning for just me',
  async function (this: ICustomWorld) {
    await fhbPage.selectPlanningFor('Just me');
    await fhbPage.selectResidency('Australian Citizen');
  }
);

Given('I enter a default salary of {string}',
  async function (this: ICustomWorld, salaryString: string) {
    const salary = FHBPage.parsePrice(salaryString);
    await fhbPage.enterSingleSalary(salary);
  }
);

Given('I enter a contract month of {string}',
  async function (this: ICustomWorld, yearMonth: string) {
    await fhbPage.enterContractMonth(yearMonth);
  }
);

// -------------------------------------------
// Buyer location
// -------------------------------------------

Given('I am buying in {string}',
  async function (this: ICustomWorld, state: string) {
    await fhbPage.selectState(state);
  }
);

// -------------------------------------------
// Property setup
// -------------------------------------------

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

// -------------------------------------------
// Action
// -------------------------------------------

When('I calculate my first home buyer plan',
  async function (this: ICustomWorld) {
    await fhbPage.calculate();
  }
);

// -------------------------------------------
// Assertions
// -------------------------------------------

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

Then('the stamp duty saving should be greater than {string}',
  async function (this: ICustomWorld, expectedValue: string) {
    const expected = FHBPage.parsePrice(expectedValue);
    const saving = await fhbPage.getStampDutySaving();  // ← was getStampDutyAmount
    expect(saving).toBeGreaterThan(expected);
  }
);