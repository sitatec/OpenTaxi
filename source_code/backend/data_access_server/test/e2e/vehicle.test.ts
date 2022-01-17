import Axios from "axios";
import { VEHICLE_URL, DEFAULT_SUCCESS_RESPONSE, DRIVER_URL } from "../constants";
import { VEHICLE } from "../fakedata";
import { execQuery } from "../utils";
import { cloneObjec, createDriver, deleteAllAccounts, getSuccessResponse } from "../utils";

const getUrlWithQuery = (queryParams: string) => VEHICLE_URL + queryParams;

const createVehicle = async () => {
  const response = await Axios.post(VEHICLE_URL, VEHICLE);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(getSuccessResponse(VEHICLE.id));
};

describe("ENDPOINT: VEHICLE", () => {

  beforeAll(async () => {
    await execQuery("DELETE FROM vehicle");
    await deleteAllAccounts();
    await createDriver();
  });

  afterAll(async () => {
    await execQuery("DELETE FROM vehicle");
    await deleteAllAccounts();
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM vehicle");
  });

  it("Should successfully create an vehicle.", createVehicle);

  it("Should successfully get an vehicle.", async () => {
    await createVehicle(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + VEHICLE.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(VEHICLE));
  });
   
  it("Should successfully get only one field from vehicle.", async () => {
    await createVehicle(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/id?id=" + VEHICLE.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse({id: VEHICLE.id}));
  });

  it("Should successfully update an vehicle.", async () => {
    await createVehicle(); // Create it first
    const newVehicle = cloneObjec(VEHICLE) as typeof VEHICLE;
    newVehicle.make = "x";

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + VEHICLE.id),
      newVehicle
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an vehicle.", async () => {
    await createVehicle(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + VEHICLE.id), {
      brand: "x",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an vehicle.", async () => {
    await createVehicle(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + VEHICLE.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
