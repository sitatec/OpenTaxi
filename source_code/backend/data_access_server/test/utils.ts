import Axios from "axios";
import { JSObject } from "../src/types";
import {
  ACCOUNT_URL,
  ADDRESS_URL,
  BOOKING_URL,
  DRIVER_URL,
  PAYMENT_URL,
  RIDER_URL,
} from "./constants";
import {
  ACCOUNT,
  ACCOUNT_1,
  ADDRESS,
  BOOKING,
  DRIVER,
  PAYMENT,
  RIDER,
} from "./fakedata";
import { Database } from "../src/db";

export const cloneObjec = (object: JSObject) =>
  JSON.parse(JSON.stringify(object));

export const getSuccessResponse = (responseData: any) => ({
  data: responseData,
  status: "success",
});

export function execQuery(query: string, queryParams?: Array<string | number>) {
  return Database.initialize().execQuery(query, queryParams);
}

export async function deleteAllAccounts() {
  return execQuery("DELETE FROM account");
}

export const createTheDefaultAccount = async () => {
  await execQuery(`DELETE FROM account WHERE id='${ACCOUNT.id}'`);
  return Axios.post(ACCOUNT_URL, ACCOUNT);
};

export const createDriver = () =>
  Axios.post(DRIVER_URL, {
    account: ACCOUNT_1,
    driver: DRIVER,
  });

export const createRider = () =>
  Axios.post(RIDER_URL, {
    account: ACCOUNT,
    rider: RIDER,
  });

export const createUsers = async () => {
  await createRider();
  return createDriver();
};

export const createAddress = async (address: typeof ADDRESS = ADDRESS) => await Axios.post(ADDRESS_URL, address);

export const createBookingWithParentTables = async () => {
  createAddress();
  const secondAddress: typeof ADDRESS = cloneObjec(ADDRESS);
  secondAddress.id = 2;
  createAddress(secondAddress);

  await createUsers();

  await Axios.post(PAYMENT_URL, PAYMENT);

  return Axios.post(BOOKING_URL, BOOKING);
};
