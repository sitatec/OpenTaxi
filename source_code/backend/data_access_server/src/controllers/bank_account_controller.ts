import { Request, Response } from "express";
import Controller from "./controller";

export default class BankAccountController extends Controller {
  createBankAccount = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.createEntity("bank_account", httpRequest, httpResponse);

  getBankAccount = (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.getEntity("bank_account", httpRequest, httpResponse);

  updateBankAccount = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.updateEntity("bank_account", httpRequest, httpResponse);

  deleteBankAccount = async (httpRequest: Request, httpResponse: Response) =>
    this.entityManager.deleteEntity("bank_account", httpRequest, httpResponse);
}
