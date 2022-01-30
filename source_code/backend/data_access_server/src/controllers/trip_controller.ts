import { Request, Response } from "express";
import { Database } from "../db";
import {
  buildInsertQueryFromJSON,
  handleDbQueryError,
} from "../utils/database_utils";
import { sendSuccessResponse } from "../utils/http_utils";
import Controller from "./controller";

export default class TripController extends Controller {
  createTrip = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("trip", httpRequest, httpResponse);

  getTrip = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("trip", httpRequest, httpResponse);

  updateTrip = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("trip", httpRequest, httpResponse);

  deleteTrip = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("trip", httpRequest, httpResponse);

  createTripWithBooking = async (
    httpRequest: Request,
    httpResponse: Response
  ) => {
    // TODO refactor.
    try {
      const data = httpRequest.body;
      if (!data.booking.rider_id || !data.booking.driver_id) {
        return httpResponse.status(400).send({
          data: "rider_id and driver_id required for the booking entity",
          status: "failure",
        });
      }
      const pickupAddressInsertionQuery = buildInsertQueryFromJSON(
        "address",
        data.pickup_address,
        "id"
      );
      const dropoffAddressInsertionQuery = buildInsertQueryFromJSON(
        "address",
        data.dropoff_address,
        "id"
      );

      let bookingId: any;
      const tripInsertionResponse = await Database.instance.wrappeInTransaction(
        async (dbClient) => {
          const insertPickupAddressResponse = await dbClient.query(
            pickupAddressInsertionQuery.text,
            pickupAddressInsertionQuery.paramValues
          );
          const insertDropoffAddressResponse = await dbClient.query(
            dropoffAddressInsertionQuery.text,
            dropoffAddressInsertionQuery.paramValues
          );

          data.booking.pickup_address_id =
            insertPickupAddressResponse.rows[0].id;
          data.booking.dropoff_address_id =
            insertDropoffAddressResponse.rows[0].id;
          const bookingInsertionQuery = buildInsertQueryFromJSON(
            "booking",
            data.booking,
            "id"
          );
          const bookingInsertionResponse = await dbClient.query(
            bookingInsertionQuery.text,
            bookingInsertionQuery.paramValues
          );
          bookingId = bookingInsertionResponse.rows[0].id;
          data.trip.booking_id = bookingId;
          const tripInsertionQuery = buildInsertQueryFromJSON(
            "trip",
            data.trip,
            "id"
          );
          return await dbClient.query(
            tripInsertionQuery.text,
            tripInsertionQuery.paramValues
          );
        }
      );
      sendSuccessResponse(httpResponse, 201, {
        trip_id: tripInsertionResponse.rows[0].id,
        booking_id: bookingId,
      });
    } catch (e) {
      console.log(`\n\n${e}\n\n`);
      handleDbQueryError(e, httpResponse);
    }
  };
}
