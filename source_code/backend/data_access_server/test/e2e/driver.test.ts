import Axios from "axios";
import { DRIVER_URL, DEFAULT_SUCCESS_RESPONSE } from "../constants";
import { ACCOUNT_1, DRIVER } from "../fakedata";
import { execQuery } from "../utils";
import { cloneObjec, getSuccessResponse } from "../utils";

const getUrlWithQuery = (queryParams: string) => DRIVER_URL + queryParams;

const createDriver = async () => {
  const response = await Axios.post(DRIVER_URL, {
    account: ACCOUNT_1,
    driver: DRIVER
  });
  expect(response.status).toBe(201);
  expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
};

describe("ENDPOINT: DRIVER", () => {
  beforeEach(async () => {
    await execQuery("DELETE FROM account");// Deleting the account will delete the
    // driver data too, because a CASCADE constraint is specified on the account_id
    // column.
  });

  it("Should successfully create a driver.", createDriver);

  it("Should successfully get a driver.", async () => {
    await createDriver(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?account_id=" + DRIVER.account_id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(DRIVER));
  });

  it("Should successfully get a driver's data.", async () => {
    await createDriver(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/data?account_id=" + DRIVER.account_id));
    expect(response.status).toBe(200);
    expect(response.data.data).toEqual(DRIVER);
  });

  it("Should successfully update an driver.", async () => {
    await createDriver(); // Create it first
    const newDriver = cloneObjec(DRIVER);
    newDriver.id_url = "lkjfls";
    newDriver.alternative_phone_number = "3646375432";

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + DRIVER.account_id),
      newDriver
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should update a driver with account data.", async () => {
    await createDriver(); // Create it first

    const newDriver = cloneObjec(DRIVER);
    newDriver.id_url = 'url';   

    const newAccount = cloneObjec(ACCOUNT_1);
    newAccount.first_name = "Elon";
    newAccount.surname = "Musk";
    delete newAccount.account_status; // To prevent security check because only 
    //admin users are able to change the status of an account.

    const response = await Axios.patch(
      getUrlWithQuery("/" + DRIVER.account_id),
      {account: newAccount, driver: newDriver}
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });// End then update it.

  it("Should successfully update only one field of a driver.", async () => {
    await createDriver(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + DRIVER.account_id), {
      id_url: "url.url/url",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete a driver.", async () => {
    await createDriver(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + DRIVER.account_id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
