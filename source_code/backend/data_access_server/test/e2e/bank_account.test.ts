import Axios from "axios";
import { BANK_ACCOUNT_URL, DEFAULT_SUCCESS_RESPONSE, DRIVER_URL } from "../constants";
import { BANK_ACCOUNT } from "../fakedata";
import { execQuery } from "../utils";
import { cloneObjec, createDriver, deleteAllAccounts, getSuccessResponse } from "../utils";

const getUrlWithQuery = (queryParams: string) => BANK_ACCOUNT_URL + queryParams;

const createBankAccount = async () => {
  const response = await Axios.post(BANK_ACCOUNT_URL, BANK_ACCOUNT);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(getSuccessResponse(BANK_ACCOUNT.id));
};

describe("ENDPOINT: BANK_ACCOUNT", () => {

  beforeAll(async () => {
    await execQuery("DELETE FROM bank_account");
    await deleteAllAccounts();
    await createDriver();
  });

  afterAll(async () => {
    await execQuery("DELETE FROM bank_account");
    await deleteAllAccounts();
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM bank_account");
  });

  it("Should successfully create an bank account.", createBankAccount);

  it("Should successfully get an bank account.", async () => {
    await createBankAccount(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + BANK_ACCOUNT.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(BANK_ACCOUNT));
  });
   
  it("Should successfully get only one field from bank account.", async () => {
    await createBankAccount(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/id?id=" + BANK_ACCOUNT.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse({id: BANK_ACCOUNT.id}));
  });

  it("Should successfully update an bank account.", async () => {
    await createBankAccount(); // Create it first
    const newBankAccount = cloneObjec(BANK_ACCOUNT) as typeof BANK_ACCOUNT;
    newBankAccount.branch_code = "x";

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + BANK_ACCOUNT.id),
      newBankAccount
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an bank account.", async () => {
    await createBankAccount(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + BANK_ACCOUNT.id), {
      account_holder_name: "x",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an bank account.", async () => {
    await createBankAccount(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + BANK_ACCOUNT.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
