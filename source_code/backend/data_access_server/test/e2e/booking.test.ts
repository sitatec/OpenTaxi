import Axios from "axios";
import { BOOKING_URL, DEFAULT_SUCCESS_RESPONSE } from "../constants";
import { BOOKING } from "../fakedata";
import {
  cloneObjec,
  createBookingWithParentTables,
  deleteAllAccounts,
  execQuery,
  getSuccessResponse,
} from "../utils";

const getUrlWithQuery = (queryParams: string) => BOOKING_URL + queryParams;

const createBooking = async () => {
  const response = await Axios.post(BOOKING_URL, BOOKING);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(getSuccessResponse(BOOKING.id));
};

describe("ENDPOINT: BOOKING", () => {
  beforeAll(async () => {
    await execQuery("DELETE FROM booking");
    await execQuery("DELETE FROM payment");
    await deleteAllAccounts();
    await execQuery("DELETE FROM address");
    await createBookingWithParentTables();
  });

  afterAll(async () => {
    await execQuery("DELETE FROM address");
    await execQuery("DELETE FROM booking");
    await execQuery("DELETE FROM payment");
    await deleteAllAccounts();
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

  it("Should successfully get only one field from booking.", async () => {
    await createBooking(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/id?id=" + BOOKING.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse({ id: BOOKING.id }));
  });

  it("Should successfully update an booking.", async () => {
    await createBooking(); // Create it first
    const newBooking = cloneObjec(BOOKING) as typeof BOOKING;
    newBooking.departure_address_id = 2;

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + BOOKING.id),
      newBooking
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an booking.", async () => {
    await createBooking(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + BOOKING.id), {
      departure_address_id: 2,
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
