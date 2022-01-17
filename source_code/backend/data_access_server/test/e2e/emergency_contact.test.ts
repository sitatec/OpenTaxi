import Axios from "axios";
import { EMERGENCY_CONTACT_URL, DEFAULT_SUCCESS_RESPONSE } from "../constants";
import { EMERGENCY_CONTACT } from "../fakedata";
import { createAddress, createRider, execQuery } from "../utils";
import { cloneObjec, createTheDefaultAccount, deleteAllAccounts, getSuccessResponse } from "../utils";

const getUrlWithQuery = (queryParams: string) => EMERGENCY_CONTACT_URL + queryParams;

const createEmergencyContact = async () => {
  const response = await Axios.post(EMERGENCY_CONTACT_URL, EMERGENCY_CONTACT);
  expect(response.status).toBe(201);
  expect(response.data).toEqual(getSuccessResponse(EMERGENCY_CONTACT.id));
};

describe("ENDPOINT: EMERGENCY_CONTACT", () => {

  beforeAll(async () => {
    await execQuery("DELETE FROM address");
    await deleteAllAccounts();
    // await execQuery("DELETE FROM emergency_contact");
    await createAddress();
    await createRider();
  });

  afterAll(async () => {
    await execQuery("DELETE FROM address");
    await deleteAllAccounts();
    // await execQuery("DELETE FROM emergency_contact");
  });

  beforeEach(async () => {
    await execQuery("DELETE FROM emergency_contact");
  });

  it("Should successfully create an emergency contact.", createEmergencyContact);

  it("Should successfully get an emergency contact.", async () => {
    await createEmergencyContact(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("?id=" + EMERGENCY_CONTACT.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse(EMERGENCY_CONTACT));
  });
  
  it("Should successfully get only one field from emergency contact.", async () => {
    await createEmergencyContact(); // Create it first
    // End then get it.
    const response = await Axios.get(getUrlWithQuery("/id?id=" + EMERGENCY_CONTACT.id));
    expect(response.status).toBe(200);
    expect(response.data).toMatchObject(getSuccessResponse({id: EMERGENCY_CONTACT.id}));
  });

  it("Should successfully update an emergency contact.", async () => {
    await createEmergencyContact(); // Create it first
    const newEmergencyContact = cloneObjec(EMERGENCY_CONTACT) as typeof EMERGENCY_CONTACT;
    newEmergencyContact.first_name = "fn";

    // End then update it.
    const response = await Axios.patch(
      getUrlWithQuery("/" + EMERGENCY_CONTACT.id),
      newEmergencyContact
    );
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully update only one field of an emergency contact.", async () => {
    await createEmergencyContact(); // Create it first

    // End then update it.
    const response = await Axios.patch(getUrlWithQuery("/" + EMERGENCY_CONTACT.id), {
      last_name: "ln",
    });
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });

  it("Should successfully delete an emergency contact.", async () => {
    await createEmergencyContact(); // Create it first
    // End then delete it.
    const response = await Axios.delete(getUrlWithQuery("/" + EMERGENCY_CONTACT.id));
    expect(response.status).toBe(200);
    expect(response.data).toEqual(DEFAULT_SUCCESS_RESPONSE);
  });
});
