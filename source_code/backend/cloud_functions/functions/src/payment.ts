import { JSObject } from "./type_alias";
import { createHash } from "crypto";
import axios from "axios";
import { URLSearchParams } from "url";

const isDevMode = ["development", "dev"].includes(
  process.env.NODE_ENV as string
);
const MARCHANT_ID = isDevMode ? "10000100" : "12166525";
const MARCHANT_KEY = isDevMode ? "46f0cd694581a" : "a3qinh6q0ph0l";
// const NOTIFY_URL = "";
const PAYFAST_URL = isDevMode
  ? "https://sandbox.payfast.co.za​/eng/process"
  : "https://www.payfast.co.za/eng/process";
const PASSPHRASE = "ROOneyRUNsALLDay74";

// TODO Error handling

export const getPayFastPaymentUrl = async (paymentData: JSObject) => {
  paymentData.merchant_id = MARCHANT_ID;
  paymentData.merchant_key = MARCHANT_KEY;
  // paymentData.notify_url = NOTIFY_URL;
  paymentData = correctDataKeysOrder(paymentData);
  const serializedData = new URLSearchParams(paymentData);
  if (!isDevMode) {
    serializedData.append("passphrase", PASSPHRASE);
  }
  paymentData.signature = md5Hash(serializedData.toString());
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
  "custom_int1",
  "custom_int2",
  "custom_int3",
  "custom_int4",
  "custom_int5",
  "custom_str1",
  "custom_str2",
  "custom_str3",
  "custom_str4",
  "custom_str5",
  "payment_method",
  "subscription_type",
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
