import { Request, Response } from "express";
import Controller from "./controller";

export default class VehicleController extends Controller {
  createVehicle = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("vehicle", httpRequest, httpResponse);

  getVehicle = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("vehicle", httpRequest, httpResponse);

  updateVehicle = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("vehicle", httpRequest, httpResponse);

  deleteVehicle = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("vehicle", httpRequest, httpResponse);
}
