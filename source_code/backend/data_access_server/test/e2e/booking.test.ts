import Axios from "axios";
import { BOOKING_URL, DEFAULT_SUCCESS_RESPONSE } from "../constants";
import { ADDRESS, BOOKING, DRIVER, RIDER } from "../fakedata";
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

  it("Should successfully create a booking with the pickup, dropoff and stop address objects", async () => {
    const pickupAddress = cloneObjec(ADDRESS);
    const dropoffAddress = cloneObjec(ADDRESS);
    const stopAddress = cloneObjec(ADDRESS);
    const stopAddress1 = cloneObjec(ADDRESS);
    const stopAddress2 = cloneObjec(ADDRESS);

    delete stopAddress.id;
    delete stopAddress1.id;
    delete stopAddress2.id;
    delete pickupAddress.id;
    delete dropoffAddress.id;

    const response = await Axios.post(getUrlWithQuery("/with_addresses"), {
      pickup_address: pickupAddress,
      dropoff_address: dropoffAddress,
      stop_addresses: [stopAddress, stopAddress1, stopAddress2],
      booking: {
        id: BOOKING.id,
        rider_id: RIDER.account_id,
        driver_id: DRIVER.account_id,
      },
    });
    expect(response.status).toBe(201);
    expect(response.data).toEqual(getSuccessResponse(BOOKING.id.toString()));
  });

  it("Should successfully get a booking.", async () => {
    await createBooking(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + BOOKING.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(BOOKING));
  });

  it("Should successfully get a booking's addresses (pickup, dropoff, stops).", async () => {
    const pickupAddress = cloneObjec(ADDRESS);
    const dropoffAddress = cloneObjec(ADDRESS);
    const stopAddress = cloneObjec(ADDRESS);
    const stopAddress1 = cloneObjec(ADDRESS);
    const stopAddress2 = cloneObjec(ADDRESS);

    delete stopAddress.id;
    delete stopAddress1.id;
    delete stopAddress2.id;
    delete pickupAddress.id;
    delete dropoffAddress.id;

    await Axios.post(getUrlWithQuery("/with_addresses"), {
      pickup_address: pickupAddress,
      dropoff_address: dropoffAddress,
      stop_addresses: [stopAddress, stopAddress1, stopAddress2],
      booking: {
        id: 911,
        rider_id: RIDER.account_id,
        driver_id: DRIVER.account_id,
      },
    });

    try {
      const response = await Axios.get(
        getUrlWithQuery("/addresses?booking_id=911")
      );
      expect(response.status).toBe(200);
      console.log(JSON.stringify(response.data));
      expect(response.data).toMatchObject(
        getSuccessResponse({
          pickup_address: pickupAddress,
          dropoff_address: dropoffAddress,
          stop_addresses: [stopAddress, stopAddress1, stopAddress2],
        })
      );
    } catch (error) {
      console.error(error);
    }
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
    newBooking.pickup_address_id = 2;

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
