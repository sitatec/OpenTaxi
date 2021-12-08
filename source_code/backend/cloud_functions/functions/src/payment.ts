import { JSObject } from "./type_alias";
import { createHash } from "crypto";
import axios from "axios";
import { URLSearchParams } from "url";

const isDevMode = ["development", "dev"].includes(
  process.env.NODE_ENV as string
);
const MARCHANT_ID = isDevMode ? "10000100" : "TODO";
const MARCHANT_KEY = isDevMode ? "46f0cd694581a" : "TODO";
const NOTIFY_URL = "";
const PAYFAST_URL = isDevMode ? "https://sandbox.payfast.co.za​/eng/process" : "TODO";

// TODO Error handling

export const getPayFastPaymentUrl = async (paymentData: JSObject) => {
  paymentData.marchant_id = MARCHANT_ID;
  paymentData.marchant_key = MARCHANT_KEY;
  paymentData.notify_url = NOTIFY_URL;
  paymentData = correctDataKeysOrder(paymentData);
  const serializedData = new URLSearchParams(paymentData).toString();
  paymentData.signature = md5Hash(serializedData);
  const response = await axios.post(PAYFAST_URL, paymentData);
  return response.headers["Location"]; // The Location header contains the redirect url.
};

const md5Hash = (data: string) => createHash("md5").update(data).digest("hex");

const ORDERED_DATA_KEYS = [
  "merchant_id",
  "merchant_key",
  "return_url",
  "cancel_url",
  "notify_url",
  "name_first",
  "name_last",
  "email_address",
  "cell_number",
  "m_payment_id",
  "amount",
  "item_name",
  "",
  "",
  "",
  "",
  "",
  "",
  "",
];

const correctDataKeysOrder = (data: JSObject) => {
  let orderedData = Object();
  ORDERED_DATA_KEYS.forEach((key) => {
    if (data.hasOwnProperty(key)) {
      orderedData[key] = data[key];
    }
  });
  return orderedData;
};
