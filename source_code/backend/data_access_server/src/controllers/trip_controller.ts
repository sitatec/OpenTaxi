import { Request, Response } from "express";
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
}
