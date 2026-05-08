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
      'json:reports/cucumber-report.json'
    ],
    parallel: 1,
    paths: ['features/**/*.feature'],
    tags: '@smoke'
  }
}