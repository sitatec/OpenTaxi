import Axios from "axios";
import { execQuery } from "../src/db";
import { JSObject } from "../src/types";
import { ACCOUNT_URL } from "./_constants";
import { ACCOUNT } from "./_fakedata";

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