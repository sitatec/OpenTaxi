import { Request, Response } from "express";
import Controller from "./controller";

export default class ReviewController extends Controller {
  createReview = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("review", httpRequest, httpResponse);

  getReview = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("review", httpRequest, httpResponse);

  updateReview = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("review", httpRequest, httpResponse);

  deleteReview = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("review", httpRequest, httpResponse);
}
