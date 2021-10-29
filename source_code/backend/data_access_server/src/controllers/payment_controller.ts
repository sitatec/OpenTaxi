import { Request, Response } from "express";
import Controller from "./controller";

export default class PaymentController extends Controller {
  createPayment = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("payment", httpRequest, httpResponse);

  getPayment = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("payment", httpRequest, httpResponse);

  updatePayment = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("payment", httpRequest, httpResponse);

  deletePayment = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("payment", httpRequest, httpResponse);
}
