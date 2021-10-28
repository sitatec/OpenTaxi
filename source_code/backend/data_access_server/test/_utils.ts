import Axios from "axios";
import { execQuery } from "../src/db";
import { JSObject } from "../src/types";
import { ACCOUNT_URL, BOOKING_URL, DRIVER_URL, PAYMENT_URL, RIDER_URL } from "./_constants";
import { ACCOUNT, ACCOUNT_1, BOOKING, DRIVER, PAYMENT, RIDER } from "./_fakedata";

export const cloneObjec = (object: JSObject) =>
  JSON.parse(JSON.stringify(object));

export const getSuccessResponse = (responseData: any) => ({
  data: responseData,
  status: "success",
});


export const deleteAllAccounts = async () => {
  await execQuery("DELETE FROM account");
};

export const createTheDefaultAccount =  () => Axios.post(ACCOUNT_URL, ACCOUNT);


export const createBookingWithParentTables = async () => {
  await Axios.post(RIDER_URL, {
    account: ACCOUNT,
    rider: RIDER,
  });

  await Axios.post(DRIVER_URL, {
    account: ACCOUNT_1,
    driver: DRIVER,
  });

  await Axios.post(PAYMENT_URL, PAYMENT);
  
  return Axios.post(BOOKING_URL, BOOKING);
}