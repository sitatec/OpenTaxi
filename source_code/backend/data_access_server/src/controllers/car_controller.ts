import { Request, Response } from "express";
import Controller from "./controller";

export default class CarController extends Controller {
  createCar = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("car", httpRequest, httpResponse);

  getCar = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("car", httpRequest, httpResponse);

  updateCar = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("car", httpRequest, httpResponse);

  deleteCar = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("car", httpRequest, httpResponse);
}
