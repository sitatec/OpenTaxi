import { Request, Response } from "express";
import Controller from "./controller";

export default class SubscriptionController extends Controller {
  createSubscription = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("subscription", httpRequest, httpResponse);

  getSubscription = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("subscription", httpRequest, httpResponse);

  updateSubscription = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("subscription", httpRequest, httpResponse);

  deleteSubscription = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("subscription", httpRequest, httpResponse);
}
