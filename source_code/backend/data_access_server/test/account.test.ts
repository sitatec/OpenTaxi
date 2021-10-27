import Axios from "axios";
import { ACCOUNT_URL, DEFAULT_SUCCESS_RESPONSE } from "./_constants";
import { ACCOUNT } from "./_fakedata";
import { execQuery } from "../src/db";
import { cloneObjec, getSuccessResponse } from "./_utils";

const getUrlWithQuery = (queryParams: string) => ACCOUNT_URL + queryParams;

const createAccount = async () => {
  const response = await Axios.post(ACCOUNT_URL, ACCOUNT);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
};

describe("ACCOUNT ENDPOINT", () => {

  beforeEach(async () => {
    await execQuery("DELETE FROM account");
  });

  test("Should successfully create an account.", createAccount);

  test("Should successfully get an account.", async () => {
    await createAccount(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + ACCOUNT.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(ACCOUNT));
  });

  test("Should successfully update an account.", async () => {
    await createAccount(); // Create it first
    const newAccount = cloneObjec(ACCOUNT);
    newAccount.first_name = "Elon";
    newAccount.surname = "Musk";
    delete newAccount.account_status; // To prevent security check because only 
    //admin users are able to change the status of an account.
    
    // End then update it.
    const response = await Axios.put(
      getUrlWithQuery("/" + ACCOUNT.id),
      newAccount
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  test("Should successfully delete an account.", async () => {
    await createAccount(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + ACCOUNT.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
