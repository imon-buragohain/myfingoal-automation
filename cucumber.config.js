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
    formatOptions: {
      snippetInterface: 'async-await'
    },
    parallel: 1,
    paths: ['features/**/*.feature']
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
    tags: '@smoke'
  },
  regression: {
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
    tags: '@regression'
  }
}