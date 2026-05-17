module.exports = {
  default: {
    requireModule: ['ts-node/register'],
    require: [
      'support/hooks.ts',
      'support/world.ts',
      'step-definitions/**/*.ts'
    ],
    format: [
      'progress-bar',
      '@cucumber/pretty-formatter',
      'allure-cucumberjs/reporter',
      'json:reports/cucumber-report.json',
      'html:reports/cucumber-report.html'
    ],
    formatOptions: { snippetInterface: 'async-await' },
    parallel: 1,
    paths: ['features/**/*.feature'],
    strict: true        // Fail if there are any undefined or pending steps
    },
  smoke: {
    requireModule: ['ts-node/register'],
    require: [
      'support/hooks.ts',
      'support/world.ts',
      'step-definitions/**/*.ts'
    ],
    format: [
      'progress-bar',
      'allure-cucumberjs/reporter',
      'json:reports/cucumber-report.json',
      'html:reports/cucumber-report.html'
    ],
    formatOptions: {
      snippetInterface: 'async-await'
    },
    parallel: 1,
    paths: ['features/**/*.feature'],
    strict: true,       // Fail if there are any undefined or pending steps
    tags: '@smoke'
  },
}