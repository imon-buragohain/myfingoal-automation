const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

const workbook = XLSX.readFile(
  path.join(__dirname, '..', 'fixtures', 'fhb-test-cases.xlsx'),
  { cellDates: true }
);
const sheet = workbook.Sheets['Sheet1'];
const rows = XLSX.utils.sheet_to_json(sheet, { 
  defval: '',
  raw: true
});

// Format contract date from Excel date serial to YYYY-MM
function formatDate(raw) {
  if (!raw || raw === '') return '2026-04';
  
  if (raw instanceof Date) {
    // Subtract timezone offset to correct for UTC shift
    // Brisbane is UTC+10, getTimezoneOffset() returns -600
    // Subtracting -600 minutes = adding 600 minutes = correct local date
    const offsetMs = raw.getTimezoneOffset() * 60 * 1000;
    const corrected = new Date(raw.getTime() - offsetMs);
    const y = corrected.getFullYear();
    const m = String(corrected.getMonth() + 1).padStart(2, '0');
    return `${y}-${m}`;
  }
  
  const str = String(raw);
  if (str.length >= 7) return str.substring(0, 7);
  return '2026-04';
}

// Derive expected stamp duty from waiver text
function stampDuty(waiver) {
  const w = String(waiver).toLowerCase();
  if (w.includes('100%')) return '$0';
  return '>$0';
}

// Derive expected HTB from eligible text
function htbStatus(eligible) {
  const e = String(eligible).toLowerCase();
  return e === 'yes' ? 'eligible' : 'not eligible';
}

// Sanitise notes — pipe characters break Cucumber's Examples table
function sanitiseNotes(notes) {
  return String(notes || '')
    .replace(/\|/g, '-')
    .replace(/\n/g, ' ')
    .trim();
}

// Build the Examples table rows
const exampleRows = rows.map(row => {
  const tc        = row['Test Case'];
  const family    = row['Family Type'];
  const residency = row['Residency Status'];
  const state     = row['State'];
  const salary    = row['Total Base Salary'];
  const propType  = row['Property Type'];
  const price     = row['Property Price'];
  const date      = formatDate(row['Contract Date']);
  const htb       = htbStatus(row['Help to Buy Eligible']);
  const fhog      = row['First Home Buyer Grant'];
  const duty      = stampDuty(row['Stamp Duty Waiver']);
  const notes     = sanitiseNotes(row['Test Scenario Notes']);

  return `      | ${tc} | ${family} | ${residency} | ${state} | $${salary} | ${propType} | $${price} | ${date} | ${duty} | $${fhog} | ${htb} | ${notes} |`;
});

const feature = `# AUTO-GENERATED — do not edit manually
# Source: fixtures/fhb-test-cases.xlsx
# Generated: ${new Date().toISOString()}
# To regenerate: node scripts/generate-excel-feature.js

Feature: FHB complete regression suite — Excel driven
  All ${rows.length} test cases loaded directly from the Excel test case register.
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
${exampleRows.join('\n')}
`;

const outputPath = path.join(
  __dirname, '..', 'features', 'fhb', 'fhb-excel.feature'
);
fs.writeFileSync(outputPath, feature, 'utf8');

console.log(`✅ Generated fhb-excel.feature with ${rows.length} test cases`);
console.log(`   Output: ${outputPath}`);