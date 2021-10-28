import Axios from "axios";
import { TRIP_URL, DEFAULT_SUCCESS_RESPONSE } from "./_constants";
import { TRIP } from "./_fakedata";
import { execQueriesInTransaction, execQuery } from "../src/db";
import { cloneObjec, createBooking, getSuccessResponse } from "./_utils";

const getUrlWithQuery = (queryParams: string) => TRIP_URL + queryParams;

const createTrip = async () => {
  const response = await Axios.post(TRIP_URL, TRIP);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
};


describe("ENDPOINT: TRIP", () => {

  beforeAll(async () => {
    await execQuery("DELETE FROM booking");
    await execQuery("DELETE FROM payment");
    await execQuery("DELETE FROM account");
    await createBooking();
  })

  afterAll(async () => {
    await execQuery("DELETE FROM trip");
    await execQuery("DELETE FROM booking");
    await execQuery("DELETE FROM payment");
    await execQuery("DELETE FROM account");
  })

  beforeEach(async () => {
    await execQuery("DELETE FROM trip");
  });

  it("Should successfully create an trip.", createTrip);

  it("Should successfully get an trip.", async () => {
    await createTrip(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + TRIP.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(TRIP));
  });

  it("Should successfully update an trip.", async () => {
    await createTrip(); // Create it first
    const newTrip = cloneObjec(TRIP) as typeof TRIP;
    newTrip.security_video_url = "http://new.url"

    // End then update it.
    const response = await Axios.put(
      getUrlWithQuery("/" + TRIP.id),
      newTrip
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an trip.", async () => {
    await createTrip(); // Create it first

    // End then update it.
    const response = await Axios.put(getUrlWithQuery("/" + TRIP.id), {
      security_video_url: "http://new.url",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an trip.", async () => {
    await createTrip(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + TRIP.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
