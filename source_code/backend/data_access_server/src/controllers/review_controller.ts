import { Request, Response } from "express";
import { wrappeResponseHandling } from "../utils/controller_utils";
import { getColumnNamesAndParams } from "../utils/database_utils";
import { getQueryParams } from "../utils/http_utils";
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
    
  getRating = async (httpRequest: Request, httpResponse: Response) => {
    const queryParams = getQueryParams(httpRequest);
    if (queryParams.length === 0) {
      return httpResponse.status(400).end();
    }
    const columnNamesAndParams = getColumnNamesAndParams(queryParams, "review");

    wrappeResponseHandling("review", queryParams, httpResponse, async () => {
      return (
        await this.entityManager.execCustomQuery(
          `SELECT AVG(rating) avg, COUNT(*) count FROM review WHERE ${columnNamesAndParams.first}`,
          columnNamesAndParams.second
        )
      ).rows[0];
    });
  };
}
