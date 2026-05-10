import {
  setWorldConstructor,
  World,
  IWorldOptions,
  setDefaultTimeout
} from '@cucumber/cucumber';
import { Browser, BrowserContext, Page } from 'playwright';
import { FHBTestCase, loadFHBTestCases } from './excel-loader';

setDefaultTimeout(60000);

// Load test cases once when the framework starts
let cachedTestCases: FHBTestCase[] | null = null;

export function getTestCases(): FHBTestCase[] {
  if (!cachedTestCases) {
    cachedTestCases = loadFHBTestCases();
    console.log(`Loaded ${cachedTestCases.length} test cases from Excel`);
  }
  return cachedTestCases;
}

export interface ICustomWorld extends World {
  browser: Browser;
  context: BrowserContext;
  page: Page;
  currentTestCase: FHBTestCase | null;
}

export class CustomWorld extends World implements ICustomWorld {
  browser!: Browser;
  context!: BrowserContext;
  page!: Page;
  currentTestCase: FHBTestCase | null = null;

  constructor(options: IWorldOptions) {
    super(options);
  }
}

setWorldConstructor(CustomWorld);