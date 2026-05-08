import { 
  setWorldConstructor, 
  World, 
  IWorldOptions,
  setDefaultTimeout
} from '@cucumber/cucumber';
import { Browser, BrowserContext, Page } from 'playwright';

setDefaultTimeout(60000);

export interface ICustomWorld extends World {
  browser: Browser;
  context: BrowserContext;
  page: Page;
}

export class CustomWorld extends World implements ICustomWorld {
  browser!: Browser;
  context!: BrowserContext;
  page!: Page;

  constructor(options: IWorldOptions) {
    super(options);
  }
}

setWorldConstructor(CustomWorld);