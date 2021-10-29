import Axios from "axios";
import { Database } from "../src/db";
import { SUBSCRIPTION_URL, DEFAULT_SUCCESS_RESPONSE, DRIVER_URL } from "./_constants";
import { SUBSCRIPTION } from "./_fakedata";
import { execQuery } from "./_utils";
import { cloneObjec, createDriver, deleteAllAccounts, getSuccessResponse } from "./_utils";

const getUrlWithQuery = (queryParams: string) => SUBSCRIPTION_URL + queryParams;

const createSubscription = async () => {
  const response = await Axios.post(SUBSCRIPTION_URL, SUBSCRIPTION);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
};

describe("ENDPOINT: SUBSCRIPTION", () => {

  beforeAll(async () => {
    await execQuery("DELETE FROM subscription");
    await deleteAllAccounts();
    await createDriver();
  });

  afterAll(async () => {
    await execQuery("DELETE FROM subscription");
    await deleteAllAccounts();
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM subscription");
  });

  it("Should successfully create an subscription.", createSubscription);

  it("Should successfully get an subscription.", async () => {
    await createSubscription(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + SUBSCRIPTION.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(SUBSCRIPTION));
  });

  it("Should successfully update an subscription.", async () => {
    await createSubscription(); // Create it first
    const newSubscription = cloneObjec(SUBSCRIPTION) as typeof SUBSCRIPTION;
    newSubscription.price = "34.32";

    // End then update it.
    const response = await Axios.put(
      getUrlWithQuery("/" + SUBSCRIPTION.id),
      newSubscription
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an subscription.", async () => {
    await createSubscription(); // Create it first

    // End then update it.
    const response = await Axios.put(getUrlWithQuery("/" + SUBSCRIPTION.id), {
      price: 0.0,
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an subscription.", async () => {
    await createSubscription(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + SUBSCRIPTION.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
