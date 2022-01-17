import { Request, Response } from "express";
import Controller from "./controller";

export default class EmergencyContactController extends Controller {
  createEmergencyContact = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("emergency_contact", httpRequest, httpResponse);

  getEmergencyContact = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("emergency_contact", httpRequest, httpResponse);

  updateEmergencyContact = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("emergency_contact", httpRequest, httpResponse);

  deleteEmergencyContact = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("emergency_contact", httpRequest, httpResponse);
}
