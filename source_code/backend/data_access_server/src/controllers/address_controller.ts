import { Request, Response } from "express";
import Controller from "./controller";

export default class AddressController extends Controller {
  createAddress = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("address", httpRequest, httpResponse);

  getAddress = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("address", httpRequest, httpResponse);

  updateAddress = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("address", httpRequest, httpResponse);

  deleteAddress = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("address", httpRequest, httpResponse);
}
