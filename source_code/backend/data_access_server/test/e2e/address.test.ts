import Axios from "axios";
import { ADDRESS_URL, DEFAULT_SUCCESS_RESPONSE } from "../constants";
import { ADDRESS } from "../fakedata";
import {
  cloneObjec,
  deleteAllAccounts,
  execQuery,
  getSuccessResponse,
} from "../utils";

const getUrlWithQuery = (queryParams: string) => ADDRESS_URL + queryParams;

const createAddress = async (address: typeof ADDRESS = ADDRESS) => {
  const response = await Axios.post(ADDRESS_URL, address);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(getSuccessResponse(address.id));
};

describe("ENDPOINT: ADDRESS", () => {
  beforeAll(async () => {
  });

  afterAll(async () => {
    await execQuery("DELETE FROM address");
    await execQuery("DELETE FROM payment");    
    await deleteAllAccounts();
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM address");
  });

  it("Should successfully create an address.", createAddress);

  it("Should successfully get an address.", async () => {
    await createAddress(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + ADDRESS.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(ADDRESS));
  });

  
  it("Should successfully get only one field from address.", async () => {
    await createAddress(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/id?id=" + ADDRESS.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse({id: ADDRESS.id}));
  });

  it("Should successfully update an address.", async () => {
    await createAddress(); // Create it first
    const newAddress = cloneObjec(ADDRESS) as typeof ADDRESS;
    newAddress.city = "new_city";

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + ADDRESS.id),
      newAddress
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an address.", async () => {
    await createAddress(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + ADDRESS.id), {
      city: "city_new",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an address.", async () => {
    await createAddress(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + ADDRESS.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
