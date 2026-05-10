const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// --- Module and tag mappings ---
const TAG_TO_MODULE = {
  'smoke':          { module: 'All_Modules',       suite: 'Smoke_Test' },
  'regression':     { module: 'All_Modules',       suite: 'Regression_Test' },
  'fhb':            { module: 'First_Home_Buyer',  suite: 'Full_Test_Suite' },
  'fhb-smoke':      { module: 'First_Home_Buyer',  suite: 'Smoke_Test' },
  'fhb-regression': { module: 'First_Home_Buyer',  suite: 'Regression_Test' },
  'fhog':           { module: 'First_Home_Buyer',  suite: 'FHOG_Tests' },      // ← add
  'htb':            { module: 'First_Home_Buyer',  suite: 'Help_To_Buy_Tests' }, // ← add
  'property-owner': { module: 'Property_Investor', suite: 'Full_Test_Suite' },
  'po-smoke':       { module: 'Property_Investor', suite: 'Smoke_Test' },
  'po-regression':  { module: 'Property_Investor', suite: 'Regression_Test' },
  'renter':         { module: 'Smart_Renter',      suite: 'Full_Test_Suite' },
  'sr-smoke':       { module: 'Smart_Renter',      suite: 'Smoke_Test' },
  'sr-regression':  { module: 'Smart_Renter',      suite: 'Regression_Test' },
  'excel': { module: 'First_Home_Buyer', suite: 'Excel_Regression' },
};

// --- Parse arguments ---
const tag = process.argv[2] || 'smoke';
const mapping = TAG_TO_MODULE[tag];

if (!mapping) {
  console.error(`\n❌ Unknown tag: "${tag}"`);
  console.error(`   Valid tags: ${Object.keys(TAG_TO_MODULE).join(', ')}\n`);
  process.exit(1);
}

const { module: moduleName, suite: suiteName } = mapping;

// --- Build timestamp and folder path ---
const now = new Date();

const dateStr = now.toLocaleDateString('en-AU', {
  year: 'numeric', month: '2-digit', day: '2-digit'
}).replace(/\//g, '-');  // DD-MM-YYYY

const timeStr = now.toLocaleTimeString('en-AU', {
  hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false
}).replace(/:/g, '-');  // HH-MM-SS

// Structure: test-runs/Run_DD-MM-YYYY/Module/Suite/Report_HH-MM-SS
const reportDir = path.join(
  'test-runs',
  `Run_${dateStr}`,
  moduleName,
  suiteName,
  `Report_${timeStr}`
);

console.log(`\n🎯 Running: ${moduleName} → ${suiteName}`);
console.log(`🏷️  Tag: @${tag}`);
console.log(`📁 Report: ${reportDir}\n`);

// --- Step 1: Clear allure-results ---
fs.rmSync('allure-results', { recursive: true, force: true });
fs.mkdirSync('allure-results', { recursive: true });

// --- Step 2: Write environment info ---
const envContent = [
  `App=myfingoal`,
  `Environment=Production`,
  `URL=${process.env.BASE_URL || 'https://myfingoal.vercel.app'}`,
  `Browser=Chromium`,
  `Module=${moduleName}`,
  `Suite=${suiteName}`,
  `Tag=@${tag}`,
  `RunTime=${now.toISOString()}`,
].join('\n');
fs.writeFileSync(
  path.join('allure-results', 'environment.properties'),
  envContent
);

// --- Step 3: Run tests ---
let testsPassed = true;
try {
  execSync(
    `npx cucumber-js --config cucumber.config.js --tags @${tag}`,
    { stdio: 'inherit' }
  );
} catch (e) {
  testsPassed = false;
  console.log('\n⚠️  Some tests failed — generating report anyway...\n');
}

// --- Step 4: Generate Allure report into timestamped folder ---
fs.mkdirSync(reportDir, { recursive: true });
execSync(
  `npx allure generate allure-results --clean -o "${reportDir}"`,
  { stdio: 'inherit' }
);

// --- Step 5: Write run summary ---
const summary = {
  tag,
  module: moduleName,
  suite: suiteName,
  runTime: now.toISOString(),
  passed: testsPassed,
  reportPath: reportDir,
};
fs.writeFileSync(
  path.join(reportDir, 'run-summary.json'),
  JSON.stringify(summary, null, 2)
);
// --- Step 6: Copy cucumber HTML report to run folder ---
const cucumberReport = path.join('reports', 'cucumber-report.html');
if (fs.existsSync(cucumberReport)) {
  fs.copyFileSync(
    cucumberReport,
    path.join(reportDir, `${suiteName}_${timeStr}.html`)
  );
  console.log(`📄 Cucumber report saved to: ${reportDir}\\${suiteName}_${timeStr}.html`);
}

// --- Step 7: Done ---
const status = testsPassed ? '✅ All tests passed' : '❌ Some tests failed';
console.log(`\n${status}`);
console.log(`📊 Report saved to: ${reportDir}`);
console.log(`\nTo open this report:`);
console.log(`   npx allure open "${reportDir}"\n`);