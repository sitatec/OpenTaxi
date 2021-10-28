import Axios from "axios";
import { RIDER_URL, DEFAULT_SUCCESS_RESPONSE } from "./_constants";
import { ACCOUNT, RIDER } from "./_fakedata";
import { execQuery } from "../src/db";
import { cloneObjec, getSuccessResponse } from "./_utils";

const getUrlWithQuery = (queryParams: string) => RIDER_URL + queryParams;

const createRider = async () => {
  const response = await Axios.post(RIDER_URL, {
    account: ACCOUNT,
    rider: RIDER,
  });
  expect(response.status).toBe(201);
  expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
};

describe("ENDPOINT: RIDER", () => {
  beforeEach(async () => {
    await execQuery("DELETE FROM account");// Deleting the account will delete the
    // rider data too, because a CASCADE constraint is specified on the account_id
    // column.
  });

  it("Should successfully create a rider.", createRider);

  it("Should successfully get a rider.", async () => {
    await createRider(); // Create it first
    // End then get it.
    const response = await Axios.get(
      getUrlWithQuery("?account_id=" + RIDER.account_id)
    );
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(RIDER));
  });

  it("Should individually update a rider.", async () => {
    await createRider(); // Create it first
    const newRider = cloneObjec(RIDER);
    newRider.driver_gender_preference = 'MALE';
    // End then update it.
    const response = await Axios.put(
      getUrlWithQuery("/" + RIDER.account_id),
      newRider
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should update a rider with account data.", async () => {
    await createRider(); // Create it first

    const newRider = cloneObjec(RIDER);
    newRider.driver_gender_preference = 'MALE';   

    const newAccount = cloneObjec(ACCOUNT);
    newAccount.first_name = "Elon";
    newAccount.surname = "Musk";
    delete newAccount.account_status; // To prevent security check because only 
    //admin users are able to change the status of an account.
    // End then update it.

    const response = await Axios.put(
      getUrlWithQuery("/" + RIDER.account_id),
      {account: newAccount, rider: newRider}
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of a driver.", async () => {
    await createRider(); // Create it first

    const response = await Axios.put(getUrlWithQuery("/" + RIDER.account_id), {
      driver_gender_preference: "FEMALE",
    });// End then update it.

    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete a rider.", async () => {
    await createRider(); // Create it first
    // End then delete it.
    const response = await Axios.delete(
      getUrlWithQuery("/" + RIDER.account_id)
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  describe("FAVORITE_DRIVER", () => {

    beforeEach(() => {
      
    });
  
    it("Should successfully add a rider's favorite driver", async () => {
      
    });

    it("Should successfully get rider's favorite drivers", async () => {
      
    });

  })

});
