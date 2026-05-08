import 'dotenv/config';
import { Before, After, BeforeAll, AfterAll, Status } from '@cucumber/cucumber';
import { chromium, Browser } from 'playwright';
import { ICustomWorld } from './world';

let browser: Browser;

BeforeAll(async () => {
  browser = await chromium.launch({
    headless: false,
    slowMo: 500
  });
});

Before(async function (this: ICustomWorld) {
  this.context = await browser.newContext({
    baseURL: 'https://myfingoal.vercel.app',
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