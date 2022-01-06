import Axios from "axios";
import { PAYMENT_URL, DEFAULT_SUCCESS_RESPONSE } from "../constants";
import { PAYMENT } from "../fakedata";
import { execQuery } from "../utils";
import { cloneObjec, createTheDefaultAccount, deleteAllAccounts, getSuccessResponse } from "../utils";

const getUrlWithQuery = (queryParams: string) => PAYMENT_URL + queryParams;

const createPayment = async () => {
  const response = await Axios.post(PAYMENT_URL, PAYMENT);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
};

describe("ENDPOINT: PAYMENT", () => {

  beforeAll(async () => {
    await execQuery("DELETE FROM payment");
    await createTheDefaultAccount()// CREATE the payer account.
  });

  afterAll(async () => {
    await execQuery("DELETE FROM payment");
    await deleteAllAccounts();
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM payment");
  });

  it("Should successfully create an payment.", createPayment);

  it("Should successfully get an payment.", async () => {
    await createPayment(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + PAYMENT.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(PAYMENT));
  });
  
  it("Should successfully get only one field from payment.", async () => {
    await createPayment(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/id?id=" + PAYMENT.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse({id: PAYMENT.id}));
  });

  it("Should successfully update an payment.", async () => {
    await createPayment(); // Create it first
    const newPayment = cloneObjec(PAYMENT) as typeof PAYMENT;
    newPayment.amount = "0.00";

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + PAYMENT.id),
      newPayment
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an payment.", async () => {
    await createPayment(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + PAYMENT.id), {
      amount: 0,
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an payment.", async () => {
    await createPayment(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + PAYMENT.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
