import Axios from "axios";
import { RIDER_URL, DEFAULT_SUCCESS_RESPONSE, DRIVER_URL } from "../constants";
import { ACCOUNT, DRIVER, RIDER } from "../fakedata";
import { execQuery } from "../utils";
import { cloneObjec, getSuccessResponse } from "../utils";

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
    await execQuery("DELETE FROM account"); // Deleting the account will delete the
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
  
  it("Should successfully get only one field from rider.", async () => {
    await createRider(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/data/account_id?account_id=" + RIDER.account_id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse({account_id: RIDER.account_id}));
  });
  
  it("Should successfully get a rider's data.", async () => {
    await createRider(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/data?account_id=" + RIDER.account_id));
    expect(response.status).toBe(200);
    expect(response.data.data).toEqual(RIDER);
  });

  it("Should individually update a rider.", async () => {
    await createRider(); // Create it first
    const newRider = cloneObjec(RIDER);
    newRider.driver_gender_preference = "MALE";
    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + RIDER.account_id),
      newRider
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should update a rider with account data.", async () => {
    await createRider(); // Create it first

    const newRider = cloneObjec(RIDER);
    newRider.driver_gender_preference = "MALE";

    const newAccount = cloneObjec(ACCOUNT);
    newAccount.first_name = "Elon";
    newAccount.surname = "Musk";
    delete newAccount.account_status; // To prevent security check because only
    //admin users are able to change the status of an account.
    // End then update it.

    const response = await Axios.patch(getUrlWithQuery("/" + RIDER.account_id), {
      account: newAccount,
      rider: newRider,
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of a driver.", async () => {
    await createRider(); // Create it first

    const response = await Axios.patch(getUrlWithQuery("/" + RIDER.account_id), {
      driver_gender_preference: "FEMALE",
    }); // End then update it.

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
});

describe("ENDPOINT: RIDER/FAVORITE_DRIVERS", () => {
  const FAVORITE_DRIVER = cloneObjec(DRIVER) as typeof DRIVER;

  const createDriver = async () => {
    const account = cloneObjec(ACCOUNT) as typeof ACCOUNT;
    account.id = ACCOUNT.id + "driver";
    account.email = "new@email.com";
    account.phone_number = "888888";

    FAVORITE_DRIVER.account_id = account.id;

    const response = await Axios.post(DRIVER_URL, {
      account: account,
      driver: FAVORITE_DRIVER,
    });

    expect(response.status).toBe(201);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  };

  const addFavoriteDriver = async () => {
    const response = await Axios.post(
      getUrlWithQuery(
        `/favorite_drivers?driver_id=${FAVORITE_DRIVER.account_id}&rider_id=${RIDER.account_id}`
      )
    );
    expect(response.status).toBe(201);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  };

  beforeAll(async () => {
    await execQuery("DELETE FROM account"); // Deleting the accounts will delete the
    // rider and the driver data too, because a CASCADE constraint is specified
    // on the account_id column.
    await createRider();
    await createDriver();
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM favorite_driver");
  });

  it("Should successfully add a rider's favorite drivers", addFavoriteDriver);

  it("Should successfully get all rider's favorite drivers", async () => {
    await addFavoriteDriver(); // Add the favorite driver first.

    const response = await Axios.get(
      getUrlWithQuery(`/favorite_drivers?rider_id=${RIDER.account_id}`)
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(getSuccessResponse(FAVORITE_DRIVER));
  });

  it("Should successfully get one rider's favorite driver", async () => {
    await addFavoriteDriver(); // Add the favorite driver first.

    const response = await Axios.get(
      getUrlWithQuery(
        `/favorite_drivers?driver_id=${FAVORITE_DRIVER.account_id}&rider_id=${RIDER.account_id}`
      )
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(getSuccessResponse(FAVORITE_DRIVER));
  });

  it("Should successfully delete all rider's favorite drivers", async () => {
    await addFavoriteDriver(); // Add the favorite driver first.

    const response = await Axios.delete(
      getUrlWithQuery(`/favorite_drivers?rider_id=${RIDER.account_id}`)
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete one rider's favorite driver", async () => {
    await addFavoriteDriver(); // Add the favorite driver first.

    const response = await Axios.delete(
      getUrlWithQuery(
        `/favorite_drivers?driver_id=${FAVORITE_DRIVER.account_id}&rider_id=${RIDER.account_id}`
      )
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
