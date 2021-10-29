/*
 * For a detailed explanation regarding each configuration property, visit:
 * https://jestjs.io/docs/configuration
 */

module.exports = {
  preset: "ts-jest",
  globalSetup: "./test/setup.ts",
  globalTeardown: "./test/teardown.ts",
  coverageDirectory: "test/coverage",
  collectCoverageFrom: ["src/**/*.ts"],
  coverageProvider: "v8"
};
