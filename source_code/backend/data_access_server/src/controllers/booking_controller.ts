import { Request, Response } from "express";
import { Query } from "pg";
import { Database } from "../db";
import {
  buildInsertQueryFromJSON,
  getRelationByColumns,
  handleDbQueryError,
} from "../utils/database_utils";
import { getQueryParams, sendSuccessResponse } from "../utils/http_utils";
import Controller from "./controller";

export default class BookingController extends Controller {
  createBooking = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("booking", httpRequest, httpResponse);

  getBooking = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("booking", httpRequest, httpResponse);

  updateBooking = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("booking", httpRequest, httpResponse);

  deleteBooking = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("booking", httpRequest, httpResponse);

  getBookingAddresses = async (
    httpRequest: Request,
    httpResponse: Response
  ) => {
    const queryParams = getQueryParams(httpRequest);
    if (!queryParams) {
      return httpResponse.status(400).end();
    }
    try {
      // TODO optimize queries.
      const pickupAddressQueryResponse =
        await this.entityManager.execCustomQuery(
          `SELECT address.* FROM booking JOIN address ON booking.id = ${queryParams[0].second} AND booking.pickup_address_id = address.id`
        );
      const pickupAddress = pickupAddressQueryResponse.rows[0];

      const dropoffAddressQueryResponse =
        await this.entityManager.execCustomQuery(
          `SELECT address.* FROM booking JOIN address ON booking.id = ${queryParams[0].second} AND booking.dropoff_address_id = address.id`
        );
      const dropoffAddress = dropoffAddressQueryResponse.rows[0];

      const stopAddresses = await getRelationByColumns(
        queryParams,
        "address",
        "booking_stop_address",
        "id",
        "address_id",
        "address",
        true
      );
      sendSuccessResponse(httpResponse, 200, {
        pickup_address: pickupAddress,
        dropoff_address: dropoffAddress,
        stop_addresses: stopAddresses,
      });
    } catch (e) {
      handleDbQueryError(e, httpResponse);
    }
  };

  createBookingWithAddresses = async (
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

      const stopAddressesInsertionQuery = (data.stop_addresses as any[]).map(
        (stopAddress: any) =>
          buildInsertQueryFromJSON("address", stopAddress, "id")
      );

      const bookingInsertionResponse =
        await Database.instance.wrappeInTransaction(async (dbClient) => {
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
          const insertBookingResponse = await dbClient.query(
            bookingInsertionQuery.text,
            bookingInsertionQuery.paramValues
          );

          const bookingId = insertBookingResponse.rows[0].id;

          for (let query of stopAddressesInsertionQuery) {
            const response = await dbClient.query(
              query.text,
              query.paramValues
            );
            const insertBookingStopAddressQuery = buildInsertQueryFromJSON(
              "booking_stop_address",
              {
                booking_id: bookingId,
                address_id: response.rows[0].id,
              }
            );
            await dbClient.query(
              insertBookingStopAddressQuery.text,
              insertBookingStopAddressQuery.paramValues
            );
          }

          return insertBookingResponse;
        });
      sendSuccessResponse(
        httpResponse,
        201,
        bookingInsertionResponse.rows[0].id
      );
    } catch (e) {
      console.error(`\n\n${e}\n\n`);
      handleDbQueryError(e, httpResponse);
    }
  };
}
