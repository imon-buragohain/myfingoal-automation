import { Page } from '@playwright/test';

export class FHBPage {

  constructor(private page: Page) {}

  // -------------------------------------------
  // Core helper — finds input by its visible
  // label text. Used because the app's labels
  // lack 'for' attributes so getByLabel() fails
  // -------------------------------------------

  private fieldByLabel = (labelText: string) =>
    this.page.locator('div.flex-col')
      .filter({
        has: this.page.locator('label', { hasText: labelText })
      })
      .locator('input')
      .first();

  // -------------------------------------------
  // Section 1 — Who is this for
  // -------------------------------------------

  private planningForButton = (type: 'Just me' | 'Couple') =>
    this.page.locator('#who')
      .getByRole('button', { name: type, exact: true });

  private stateDropdown = () =>
    this.page.getByRole('combobox');

  private residencyButton = (
    type: 'Australian Citizen' | 'Permanent Resident'
  ) =>
    this.page.getByRole('button', { name: type, exact: true });

  // -------------------------------------------
  // Section 2 — Income
  // -------------------------------------------

  private singleSalaryInput = () =>
    this.fieldByLabel('Annual salary');

  private person1SalaryInput = () =>
    this.page.locator('div.flex-col')
      .filter({
        has: this.page.locator('label', { hasText: 'Annual salary' })
      })
      .locator('input')
      .nth(0);

  private partnerSalaryInput = () =>
    this.page.locator('div.flex-col')
      .filter({
        has: this.page.locator('label', { hasText: 'Annual salary' })
      })
      .locator('input')
      .nth(1);

  // -------------------------------------------
  // Section 3 — Your Target Property
  // -------------------------------------------

  private propertyTypeButton = (type: 'New Build' | 'Established') =>
    this.page.getByRole('button', { name: new RegExp(type, 'i') });

  private propertyPriceInput = () =>
    this.page.locator('#property input[type="text"]');

  private contractMonthInput = () =>
    this.page.locator('input[type="month"]');

  // -------------------------------------------
  // Calculate button
  // -------------------------------------------

  private calculateButton = () =>
    this.page.getByRole('button', {
      name: /Calculate My Path to Ownership/i
    });

  // -------------------------------------------
  // Results — Stamp duty
  // -------------------------------------------

  private stampDutyRow = () =>
    this.page.locator('div.flex.items-center.justify-between')
      .filter({
        has: this.page.locator('span.text-sm.text-gray-700',
          { hasText: 'Stamp duty' })
      })
      .first();

  private stampDutyAmountLocator = () =>
    this.stampDutyRow().locator('span.font-semibold.text-sm');

  private stampDutyExemptionBadge = () =>
    this.stampDutyRow().locator('span.italic');

  private stampDutySavingRow = () =>
    this.page.locator('div.flex.items-center.justify-between')
      .filter({
        has: this.page.locator('span', { hasText: 'Stamp duty saving' })
      })
      .first();

  // -------------------------------------------
  // Results — First Home Owner Grant
  // -------------------------------------------

  private fhogRow = () =>
    this.page.locator('div.flex.items-center.justify-between')
      .filter({
        has: this.page.locator('span.text-sm.text-gray-700',
          { hasText: 'First Home Owner Grant' })
      })
      .first();

  private fhogAmountLocator = () =>
    this.fhogRow().locator('span.font-semibold.text-sm');

  private fhogBadge = () =>
    this.fhogRow().locator('span.italic');

  // -------------------------------------------
  // Results — Help to Buy
  // -------------------------------------------

  private helpToBuyEligibleBadge = () =>
    this.page.getByText('✓ Eligible').nth(2);

  private helpToBuyNotEligibleBadge = () =>
    this.page.getByText('✗ Not eligible');

  // -------------------------------------------
  // Actions — Section 1
  // -------------------------------------------

  async selectPlanningFor(type: 'Just me' | 'Couple') {
    await this.planningForButton(type).click();
  }

  async selectState(state: string) {
    await this.stateDropdown().selectOption(state);
  }

  async selectResidency(
    type: 'Australian Citizen' | 'Permanent Resident'
  ) {
    await this.residencyButton(type).click();
  }

  // -------------------------------------------
  // Actions — Section 2
  // -------------------------------------------

  async enterSingleSalary(salary: number) {
    const input = this.singleSalaryInput();
    const count = await input.count();
    console.log(`Found ${count} salary input(s)`);
    await input.click();
    await input.fill(salary.toString());
  }

  async enterCoupleSalaries(
    person1Salary: number,
    partnerSalary: number
  ) {
    await this.person1SalaryInput().click();
    await this.person1SalaryInput().fill(person1Salary.toString());
    await this.partnerSalaryInput().click();
    await this.partnerSalaryInput().fill(partnerSalary.toString());
  }

  // -------------------------------------------
  // Actions — Section 3
  // -------------------------------------------

  async selectPropertyType(type: 'New Build' | 'Established') {
    await this.propertyTypeButton(type).click();
  }

  async enterPropertyPrice(price: number) {
    const input = this.propertyPriceInput();
    await input.click();
    await input.fill(price.toString());
  }

  async enterContractMonth(yearMonth: string) {
    await this.contractMonthInput().fill(yearMonth);
  }

  // -------------------------------------------
  // Actions — Calculate
  // -------------------------------------------

  async calculate() {
    await this.calculateButton().click();
    await this.page.waitForSelector(
      'text=Your Path to Purchase',
      { timeout: 30000 }
    );
  }

  // -------------------------------------------
  // Getters — Stamp duty
  // -------------------------------------------

  async getStampDutyAmount(): Promise<number> {
    const row = this.stampDutyRow();
    const count = await row.count();
    console.log(`Found ${count} stamp duty row(s)`);
    const text = await this.stampDutyAmountLocator().textContent();
    console.log(`Stamp duty amount text: "${text}"`);
    return FHBPage.parseCurrency(text ?? '0');
  }

  async hasFullExemption(): Promise<boolean> {
    const badge = this.stampDutyExemptionBadge();
    const count = await badge.count();
    console.log(`Found ${count} exemption badge(s)`);
    if (count === 0) return false;
    const text = await badge.textContent();
    console.log(`Exemption badge text: "${text}"`);
    return (text ?? '').includes('Full exemption');
  }

  async getStampDutySaving(): Promise<number> {
    const text = await this.stampDutySavingRow()
      .locator('span.font-bold')
      .textContent();
    console.log(`Stamp duty saving text: "${text}"`);
    return FHBPage.parseCurrency(text ?? '0');
  }

  // -------------------------------------------
  // Getters — FHOG
  // -------------------------------------------

  async getFHOGAmount(): Promise<number> {
    const text = await this.fhogAmountLocator().textContent();
    console.log(`FHOG amount text: "${text}"`);
    return FHBPage.parseCurrency(text ?? '0');
  }

  async isFHOGEligible(): Promise<boolean> {
    const badge = this.fhogBadge();
    const count = await badge.count();
    if (count === 0) return false;
    const text = await badge.textContent();
    return !(text ?? '').toLowerCase().includes('not eligible');
  }

  // -------------------------------------------
  // Getters — Help to Buy
  // -------------------------------------------

  async isHelpToBuyEligible(): Promise<boolean> {
    const notEligible = this.helpToBuyNotEligibleBadge();
    const notEligibleCount = await notEligible.count();
    if (notEligibleCount > 0) return false;
    const eligible = this.helpToBuyEligibleBadge();
    const eligibleCount = await eligible.count();
    return eligibleCount > 0;
  }

  async getHelpToBuyStatus(): Promise<string> {
    const notEligible = this.helpToBuyNotEligibleBadge();
    const count = await notEligible.count();
    if (count > 0) {
      const text = await notEligible.textContent();
      console.log(`HTB status: "${text}"`);
      return 'not eligible';
    }
    console.log('HTB status: eligible');
    return 'eligible';
  }

  // -------------------------------------------
  // Static helpers
  // -------------------------------------------

  static parseCurrency(text: string): number {
    return parseFloat(text.replace(/[$,\s−-]/g, '')) || 0;
  }

  static parsePrice(priceString: string): number {
    return parseFloat(priceString.replace(/[$,\s]/g, '')) || 0;
  }
}