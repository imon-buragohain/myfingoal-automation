import 'dotenv/config';
import { Before, After, BeforeAll, AfterAll, Status } from '@cucumber/cucumber';
import { chromium, Browser } from 'playwright';
import { ICustomWorld } from './world';
import * as fs from 'fs';
import * as path from 'path';

let browser: Browser;

BeforeAll(async () => {
  // Write environment info to Allure results
  const envContent = [
    `App=myfingoal`,
    `Environment=Production`,
    `URL=${process.env.BASE_URL || 'https://myfingoal.vercel.app'}`,
    `Browser=Chromium`,
    `Platform=Windows 11`,
  ].join('\n');

  fs.mkdirSync('allure-results', { recursive: true });
  fs.writeFileSync(
    path.join('allure-results', 'environment.properties'),
    envContent
  );

  browser = await chromium.launch({
    headless: false,
    slowMo: 500
  });
});

Before(async function (this: ICustomWorld) {
  this.context = await browser.newContext({
    baseURL: process.env.BASE_URL || 'https://myfingoal.vercel.app',
    viewport: { width: 1280, height: 720 }
  });
  this.page = await this.context.newPage();
});

After(async function (this: ICustomWorld, scenario) {
  if (scenario.result?.status === Status.FAILED) {
    try {
      const screenshot = await this.page.screenshot({ fullPage: true });
      await this.attach(screenshot, 'image/png');
    } catch (e) {
      console.log('Screenshot failed:', e);
    }
  }
  await this.page.close();
  await this.context.close();
});

AfterAll(async () => {
  await browser.close();
});