import Axios from "axios";
import { CAR_URL, DEFAULT_SUCCESS_RESPONSE, DRIVER_URL } from "../constants";
import { CAR } from "../fakedata";
import { execQuery } from "../utils";
import { cloneObjec, createDriver, deleteAllAccounts, getSuccessResponse } from "../utils";

const getUrlWithQuery = (queryParams: string) => CAR_URL + queryParams;

const createCar = async () => {
  const response = await Axios.post(CAR_URL, CAR);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(getSuccessResponse(CAR.id));
};

describe("ENDPOINT: CAR", () => {

  beforeAll(async () => {
    await execQuery("DELETE FROM car");
    await deleteAllAccounts();
    await createDriver();
  });

  afterAll(async () => {
    await execQuery("DELETE FROM car");
    await deleteAllAccounts();
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM car");
  });

  it("Should successfully create an car.", createCar);

  it("Should successfully get an car.", async () => {
    await createCar(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + CAR.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(CAR));
  });
   
  it("Should successfully get only one field from car.", async () => {
    await createCar(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/id?id=" + CAR.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse({id: CAR.id}));
  });

  it("Should successfully update an car.", async () => {
    await createCar(); // Create it first
    const newCar = cloneObjec(CAR) as typeof CAR;
    newCar.brand = "x";

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + CAR.id),
      newCar
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an car.", async () => {
    await createCar(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + CAR.id), {
      brand: "x",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an car.", async () => {
    await createCar(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + CAR.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
