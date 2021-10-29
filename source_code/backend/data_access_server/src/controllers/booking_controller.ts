import { Request, Response } from "express";
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
}
