import Axios from "axios";
import { BOOKING_URL, DEFAULT_SUCCESS_RESPONSE } from "./_constants";
import { BOOKING } from "./_fakedata";
import { execQuery } from "../src/db";
import {
  cloneObjec,
  createBookingWithParentTables,
  getSuccessResponse,
} from "./_utils";

const getUrlWithQuery = (queryParams: string) => BOOKING_URL + queryParams;

const createBooking = async () => {
  const response = await Axios.post(BOOKING_URL, BOOKING);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
};

describe("ENDPOINT: BOOKING", () => {
  beforeAll(async () => {
    await execQuery("DELETE FROM payment");
    await execQuery("DELETE FROM account");
    await createBookingWithParentTables();
  });

  afterAll(async () => {
    await execQuery("DELETE FROM booking");
    await execQuery("DELETE FROM payment");
    await execQuery("DELETE FROM account");
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM booking");
  });

  it("Should successfully create an booking.", createBooking);

  it("Should successfully get an booking.", async () => {
    await createBooking(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + BOOKING.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(BOOKING));
  });

  it("Should successfully update an booking.", async () => {
    await createBooking(); // Create it first
    const newBooking = cloneObjec(BOOKING) as typeof BOOKING;
    newBooking.departure_address = "halurl";

    // End then update it.
    const response = await Axios.put(
      getUrlWithQuery("/" + BOOKING.id),
      newBooking
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an booking.", async () => {
    await createBooking(); // Create it first

    // End then update it.
    const response = await Axios.put(getUrlWithQuery("/" + BOOKING.id), {
      departure_address: "httrl",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an booking.", async () => {
    await createBooking(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + BOOKING.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
