# myfingoal-automation

**Playwright + Cucumber + TypeScript — Enterprise Test Automation Framework**

---

## Why this project exists

Most QA automation portfolios have the same problem — they're built on demo apps, todo lists, or e-commerce sandboxes that exist purely to be tested. The tests look clean but they don't tell an employer anything meaningful about how you'd operate in a real environment.

I wanted to do something different.

As a Test Manager, I spend a lot of time thinking about automation strategy — which tools to use, how to structure frameworks, how to make test suites maintainable at scale. What I don't get enough of is hands-on time writing the actual code. There are real constraints in enterprise environments: procurement hurdles, unwillingness to adopt open source tools, legacy applications that aren't automation-friendly, and the reality that framework decisions are often made before you arrive.

So I built my own production app first.

**myfingoal** is a genuine Australian family financial planning application — React frontend, Python FastAPI backend, deployed on Vercel and Railway. It handles real calculations: 2025-26 ATO tax rates, age pension means testing, stamp duty rules for all 8 Australian states, the First Home Guarantee Scheme, Help to Buy eligibility, negative gearing, FHSS scheme withdrawals. It's not a toy. It's the kind of domain complexity you'd find at a fintech.

Then I built this automation framework on top of it.

---

## What's being tested

The myfingoal First Home Buyer stream — three business rule categories tested across all 8 Australian states:

| Category | What it checks |
|---|---|
| Stamp duty | Full exemption, partial concession, or full duty based on state, property type, and price |
| First Home Owner Grant | Grant amount by state (QLD $30k/$15k, NSW $10k, VIC $10k, SA $15k, TAS $30k, NT $50k, ACT $0) |
| Help to Buy eligibility | Income caps, citizenship requirement, state participation, price caps |

The test data comes from a manual test case register (Excel) that I built when I was creating the functional specification and use cases of the product - 43 test cases. The framework reads it directly and generates the test suite automatically — no copy-pasting between spreadsheets and feature files.

---

## Framework architecture

```
Playwright        — browser automation
Cucumber          — BDD test runner, Gherkin feature files
TypeScript        — type-safe step definitions and page objects
Allure            — HTML reporting with environment metadata
GitHub Actions    — CI/CD pipeline, runs on push and nightly schedule
GitHub Pages      — public report URL, always shows latest run
```

The design follows the Page Object Model — all locators and interactions live in `pages/FHBPage.ts`, step definitions stay clean and readable. When the UI changes, one file gets updated, not forty tests.

---

## How the framework is wired together

Three files do the heavy lifting before a single test runs.

**`support/world.ts`** defines the shared context — the Playwright browser, context, and page objects that every step definition can access. It also sets the global step timeout to 60 seconds, overriding Cucumber's default 5 seconds which isn't enough for a React app to render.

```typescript
setDefaultTimeout(60000);

export interface ICustomWorld extends World {
  browser: Browser;
  context: BrowserContext;
  page: Page;
}
```

**`support/hooks.ts`** manages the browser lifecycle. Chrome launches once before all tests, a fresh context and tab opens before each scenario, and closes after. If a scenario fails, a full-page screenshot is automatically attached to the Allure report — no configuration needed per test.

```typescript
BeforeAll(async () => {
  browser = await chromium.launch({
    headless: process.env.CI === 'true',  // headed locally, headless in CI
    slowMo: process.env.CI === 'true' ? 0 : 500
  });
});

After(async function (this: ICustomWorld, scenario) {
  if (scenario.result?.status === Status.FAILED) {
    const screenshot = await this.page.screenshot({ fullPage: true });
    await this.attach(screenshot, 'image/png');
  }
});
```

**`cucumber.config.js`** tells Cucumber where everything lives and sets parallel execution to 1. Parallel > 1 requires isolated browser instances per worker — that's a later iteration once the suite is larger.

```javascript
module.exports = {
  default: {
    requireModule: ['ts-node/register'],
    require: ['support/hooks.ts', 'support/world.ts', 'step-definitions/**/*.ts'],
    paths: ['features/**/*.feature'],
    parallel: 1
  }
}
```

## The Excel-driven test approach

One thing I was deliberate about: the test data lives in a spreadsheet, not in the feature file.

```
fixtures/fhb-test-cases.xlsx  (43 rows, manually verified)
        ↓
scripts/generate-excel-feature.js  reads it at runtime
        ↓
features/fhb/fhb-excel.feature  auto-generated before each run
        ↓
43 Cucumber scenarios execute, one per row
```

The reason for this is practical. In a team environment, the people who own the business rules — business analysts, product owners, SMEs — are comfortable in Excel. They shouldn't need to edit a `.feature` file to add a test case. This approach lets them manage test data in a format they already know, and the framework picks it up automatically.

---

## Running the tests

```bash
# Install
npm install
npx playwright install chromium

# Smoke tests (2 scenarios, ~20 seconds)
npm run test:smoke

# FHOG tests
npm run test:fhog

# Help to Buy tests
npm run test:htb

# Full Excel-driven regression (43 scenarios)
npm run test:excel

# Generate Excel feature file manually
npm run generate:excel
```

Reports are saved to `test-runs/Run_DD-MM-YYYY/Module/Suite/Report_HH-MM-SS/` with both an Allure report and a standalone HTML file that opens directly in any browser.

---

## CI/CD pipeline

Every push to `main` triggers the GitHub Actions workflow:

1. Ubuntu runner spins up
2. Dependencies installed via `npm ci` (exact versions from lock file)
3. Chromium installed headless
4. Smoke tests run against live production app
5. Allure report generated and published to GitHub Pages

The pipeline also runs on a nightly schedule — 8am AEST — so any changes to the live application are caught automatically, not just when test code changes.

**Live report:** https://imon-buragohain.github.io/myfingoal-automation/latest/

**Live application being tested:** url will be provided on request

---

## Project structure

```
myfingoal-automation/
├── features/
│   └── fhb/
│       ├── stamp-duty.feature        ← smoke tests, hardcoded boundary cases
│       ├── fhog.feature              ← FHOG eligibility across states
│       ├── help-to-buy.feature       ← HTB eligibility scenarios
│       └── fhb-excel.feature         ← auto-generated from Excel (43 scenarios)
├── step-definitions/
│   └── fhb/
│       ├── stamp-duty.steps.ts
│       └── fhog-htb.steps.ts
├── pages/
│   └── FHBPage.ts                    ← all locators and interactions
├── support/
│   ├── hooks.ts                      ← browser lifecycle, screenshots on failure
│   └── world.ts                      ← shared Playwright context
├── fixtures/
│   ├── fhb-test-cases.xlsx           ← 43 manually verified test cases
│   └── stamp-duty-scenarios.json
├── scripts/
│   ├── run-tests.js                  ← orchestrates test run + report generation
│   └── generate-excel-feature.js     ← reads Excel, writes feature file
└── .github/
    └── workflows/
        └── smoke-tests.yml           ← CI pipeline definition
```

---

## What I learned building this

A few things stood out that I wouldn't have learned from a course or a tutorial:

**React SPAs need different navigation handling.** `goto()` completes before React renders anything. You need to wait for a meaningful element, not just `networkidle` — which never settles on a SPA anyway.

**Labels without `for` attributes break `getByLabel()`.** The myfingoal app's form labels aren't programmatically associated with their inputs. This was intentionally done to ensure the test automation framework all kinds of elements. The fix was a container-scoped locator that finds the input through its parent div.

**Excel dates are a timezone trap.** The `xlsx` library reads Excel date serials as UTC midnight. If you call `getMonth()` without correcting for local timezone offset, Brisbane's UTC+10 shifts the date back to the previous day — and often the previous month. The fix is to apply `getTimezoneOffset()` before reading the date values.

**`npm ci` over `npm install` in CI.** `npm install` can silently update patch versions. `npm ci` enforces exact versions from the lock file and fails loudly if there's a mismatch. That determinism matters when you're debugging a CI failure at 9am.

---

## My Background

I'm a Test Manager with experience across different applications and enterprise software over the last 20 years. In a previous role I successfully designed and implemented an automation strategy for a Warehouse Management System — same stack as this project: Cucumber, Playwright, TypeScript, Allure. That engagement was successful, but my involvement was primarily strategic: framework architecture decisions, tool selection, team oversight, stakeholder reporting, and keeping the programme on track. The day-to-day technical decisions and actual script writing were handled by the automation engineers I was leading.

That's a honest description of what Test Managers do. But it left a gap I wanted to close.

This project was built to fill that gap. I wanted to understand every line — why a locator is written one way and not another, what actually happens when a React SPA doesn't finish rendering before Playwright tries to interact with it, how timezone offsets corrupt Excel dates in ways that aren't obvious until 2am. The kind of things you only learn by being the person who hits the problem and has to fix it.
