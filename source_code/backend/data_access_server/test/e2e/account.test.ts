import Axios from "axios";
import {
  ACCOUNT_URL,
  DEFAULT_SUCCESS_RESPONSE,
  REVIEW_URL,
} from "../constants";
import { ACCOUNT, REVIEW } from "../fakedata";
import {
  cloneObjec,
  createTheDefaultAccount,
  createUsers,
  deleteAllAccounts,
  execQuery,
  getSuccessResponse,
} from "../utils";

const getUrlWithQuery = (queryParams: string) => ACCOUNT_URL + queryParams;

const createAccount = async () => {
  const response = await createTheDefaultAccount();
  expect(response.status).toBe(201);
  expect(response.data).toEqual(getSuccessResponse(ACCOUNT.id));
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

  it("Should successfully get only one field from account.", async () => {
    await createAccount(); // Create it first
    // End then get it.
    const response = await Axios.get(
      getUrlWithQuery("/first_name?id=" + ACCOUNT.id)
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(
      getSuccessResponse({ first_name: ACCOUNT.first_name })
    );
  });

  it("Should successfully get only some fields from account.", async () => {
    await createAccount(); // Create it first
    // End then get it.
    const response = await Axios.get(
      getUrlWithQuery("/id,first_name,last_name,email?id=" + ACCOUNT.id)
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(
      getSuccessResponse({
        first_name: ACCOUNT.first_name,
        id: ACCOUNT.id,
        last_name: ACCOUNT.last_name,
        email: ACCOUNT.email,
      })
    );
  });

  it("Should successfully update an account.", async () => {
    await createAccount(); // Create it first
    const newAccount = cloneObjec(ACCOUNT);
    newAccount.first_name = "Elon";
    newAccount.last_name = "Musk";
    delete newAccount.account_status; // To prevent security check because only
    //admin users are able to change the status of an account.

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + ACCOUNT.id),
      newAccount
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an account.", async () => {
    await createAccount(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + ACCOUNT.id), {
      last_name: "Musk",
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

  it("Should successfully get an account's notification token.", async () => {
    await createAccount(); // Create it first
    // End then get it.
    const response = await Axios.get(
      getUrlWithQuery("/notification_token?id=" + ACCOUNT.id)
    );
    expect(response.status).toBe(200);
    expect(response.data.data.notification_token).toEqual(
      ACCOUNT.notification_token
    );
  });
});
