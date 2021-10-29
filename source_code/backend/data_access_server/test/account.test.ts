import Axios from "axios";
import { ACCOUNT_URL, DEFAULT_SUCCESS_RESPONSE } from "./_constants";
import { ACCOUNT } from "./_fakedata";
import { cloneObjec, createTheDefaultAccount, deleteAllAccounts, getSuccessResponse } from "./_utils";

const getUrlWithQuery = (queryParams: string) => ACCOUNT_URL + queryParams;

const createAccount = async () => {
  const response = await createTheDefaultAccount();
  expect(response.status).toBe(201);
  expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
};

describe("ENDPOINT: ACCOUNT", () => {
  beforeEach(async () => {
    await deleteAllAccounts();
  });

  it("Should successfully create an account.", createAccount);

  it("Should successfully get an account.", async () => {
    await createAccount(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + ACCOUNT.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(ACCOUNT));
  });

  it("Should successfully update an account.", async () => {
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

  it("Should successfully update only one field of an account.", async () => {
    await createAccount(); // Create it first

    // End then update it.
    const response = await Axios.put(getUrlWithQuery("/" + ACCOUNT.id), {
      surname: "Musk",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an account.", async () => {
    await createAccount(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + ACCOUNT.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
