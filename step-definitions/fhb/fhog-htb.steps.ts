import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import { ICustomWorld } from '../../support/world';
import { FHBPage } from '../../pages/FHBPage';

let fhbPage: FHBPage;

// -------------------------------------------
// Navigation — shared across all FHB features
// Already in stamp-duty.steps.ts but Cucumber
// handles duplicates gracefully if identical
// -------------------------------------------

// -------------------------------------------
// Buyer setup — extended for Excel data
// -------------------------------------------

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

Given('I enter a salary of {string}',
  async function (this: ICustomWorld, salaryString: string) {
    const salary = FHBPage.parsePrice(salaryString);
    // Check if couple mode is active by looking for Person 1 label
    const isCouple = await this.page.locator('text=Person 1').count() > 0;
    if (isCouple) {
      // Split salary equally between partners
      const each = Math.floor(salary / 2);
      await fhbPage.enterCoupleSalaries(each, each);
    } else {
      await fhbPage.enterSingleSalary(salary);
    }
  }
);

Given('I enter a combined salary of {string}',
  async function (this: ICustomWorld, salaryString: string) {
    // For couple scenarios — splits salary equally between partners
    const total = FHBPage.parsePrice(salaryString);
    const each = Math.floor(total / 2);
    await fhbPage.enterCoupleSalaries(each, each);
  }
);

// -------------------------------------------
// FHOG assertions
// -------------------------------------------

Then('the First Home Owner Grant should be {string}',
  async function (this: ICustomWorld, expectedValue: string) {
    const expected = FHBPage.parsePrice(expectedValue);
    const actual = await fhbPage.getFHOGAmount();
    console.log(`FHOG expected: $${expected}, actual: $${actual}`);
    expect(actual).toBe(expected);
  }
);

Then('the First Home Owner Grant should not be available',
  async function (this: ICustomWorld) {
    const eligible = await fhbPage.isFHOGEligible();
    expect(eligible).toBe(false);
  }
);

// -------------------------------------------
// Help to Buy assertions
// -------------------------------------------

Then('Help to Buy should be {string}',
  async function (this: ICustomWorld, expectedStatus: string) {
    const actual = await fhbPage.getHelpToBuyStatus();
    console.log(`HTB expected: ${expectedStatus}, actual: ${actual}`);
    expect(actual).toBe(expectedStatus.toLowerCase());
  }
);