import Axios from "axios";
import { REVIEW_URL, DEFAULT_SUCCESS_RESPONSE } from "../constants";
import { REVIEW } from "../fakedata";
import { createBookingWithParentTables, execQuery } from "../utils";
import {
  cloneObjec,
  createUsers,
  deleteAllAccounts,
  getSuccessResponse,
} from "../utils";
import { createTrip } from "./trip.test";

const getUrlWithQuery = (queryParams: string) => REVIEW_URL + queryParams;

const createReview = async () => {
  const response = await Axios.post(REVIEW_URL, REVIEW);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(getSuccessResponse(REVIEW.id));
};

describe("ENDPOINT: REVIEW", () => {
  beforeAll(async () => {
    await execQuery("DELETE FROM review");
    await execQuery("DELETE FROM trip");
    await execQuery("DELETE FROM booking");
    await deleteAllAccounts();
    await createBookingWithParentTables();
    createTrip();
  });

  afterAll(async () => {
    await execQuery("DELETE FROM review");
    await execQuery("DELETE FROM trip");
    await execQuery("DELETE FROM booking");
    await deleteAllAccounts();
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM review");
  });

  it("Should successfully create an review.", createReview);

  it("Should successfully get an review.", async () => {
    await createReview(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + REVIEW.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(REVIEW));
  });

  it("Should successfully get only one field from review.", async () => {
    await createReview(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/id?id=" + REVIEW.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse({ id: REVIEW.id }));
  });

  it("Should successfully update an review.", async () => {
    await createReview(); // Create it first
    const newReview = cloneObjec(REVIEW) as typeof REVIEW;
    newReview.comment = "halurl";

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + REVIEW.id),
      newReview
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an review.", async () => {
    await createReview(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + REVIEW.id), {
      comment: "httrl",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an review.", async () => {
    await createReview(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + REVIEW.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully get an account's rating", async () => {
    await createReview();
    // GET rating
    const response = await Axios.get(
      getUrlWithQuery("/rating?recipient_id=" + REVIEW.recipient_id)
    );
    expect(response.status).toBe(200);
    response.data.data.avg = parseFloat(response.data.data.avg);
    expect(response.data).toEqual(
      getSuccessResponse({ avg: REVIEW.rating, count: "1" })
    );
  });
});
