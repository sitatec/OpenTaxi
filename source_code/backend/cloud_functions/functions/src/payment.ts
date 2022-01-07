import { JSObject } from "./type_alias";
import { createHash } from "crypto";
import axios from "axios";
import { URLSearchParams } from "url";
import { ACCOUNT_DATA_ACCESS_URL, DATA_ACCESS_SERVER_URL } from "./constants";
import * as functions from "firebase-functions";

const isDevMode = ["development", "dev"].includes(
  process.env.NODE_ENV as string
);
const MARCHANT_ID = isDevMode ? "10000100" : "12166525";
const MARCHANT_KEY = isDevMode ? "46f0cd694581a" : "a3qinh6q0ph0l";
const SUBSCRIPTION_URL = isDevMode
  ? "https://api.payfast.co.za/subscriptions/${subscriptionToken}/fetch?testing=true"
  : "https://api.payfast.co.za/subscriptions/${subscriptionToken}/fetch";
const TOKEN_PAYMENT_URL = isDevMode
  ? "https://api.payfast.co.za/subscriptions/${data.token}/adhoc?testing=true"
  : "https://api.payfast.co.za/subscriptions/${data.token}/adhoc";
// const NOTIFY_URL = "";
const PAYFAST_URL = isDevMode
  ? "https://sandbox.payfast.co.za​/eng/process"
  : "https://www.payfast.co.za/eng/process";
const PASSPHRASE = "ROOneyRUNsALLDay74";

enum TransactionNotificationType {
  DRIVER_SUBSCRIPTION = 0,
  RIDER_TOKENIZED_PAYMENT = 1,
}

// ############################# GET URL ################################# //

// TODO Error handling
export const getPayFastPaymentUrl = async (paymentData: JSObject) => {
  paymentData.merchant_id = MARCHANT_ID;
  paymentData.merchant_key = MARCHANT_KEY;
  // paymentData.notify_url = NOTIFY_URL;
  paymentData = correctDataKeysOrder(paymentData);
  const serializedData = new URLSearchParams(paymentData);
  serializedData.append("passphrase", PASSPHRASE);
  paymentData.signature = md5Hash(serializedData.toString());
  const response = await axios.post(PAYFAST_URL, paymentData);
  return response.request.res.responseUrl; // The redirect url.
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

// ########################## TRANSACTION NOTIFICATION ########################### //

export const receiveTransationNotification = async (data: JSObject) => {
  const token = data.token;
  const userId = data.custom_str1;
  if (!token || !userId) {
    console.log(
      `\n-------\nReceived NON COMPLETE transaction notification for new subscription \nTOKEN = ${token} \nUSER_ID = ${userId} \nTRANSACTION_STATUS = ${data.payment_status} .\n-------\n`
    );
    return;
    // TODO notify admin something wrong.
  }
  if (data.payment_status == "COMPLETE" && (await isNewSubscription(token))) {
    await saveTokenForNewSubscription(token, userId);
  }
  const notificationType = data.custom_int1;
  if (notificationType == TransactionNotificationType.DRIVER_SUBSCRIPTION) {
    if (data.payment_status == "COMPLETE") {
      // TODO generate invoice and send email to driver.
    } else {
      // TODO notify admin by email
    }
  }
};

const isNewSubscription = async (subscriptionToken: string) => {
  const header = {
    "merchant-id": MARCHANT_ID,
    version: "v1",
    timestamp: new Date().toISOString(),
  };

  const serializedSortedData = new URLSearchParams({
    ...header,
    passphrase: PASSPHRASE,
  });
  serializedSortedData.sort();
  header["signature"] = md5Hash(serializedSortedData.toString());
  const url = eval("`" + SUBSCRIPTION_URL + "`");
  const response = await axios.get(url, { headers: header });
  return response.data.data.cycles_complete == 1;
};

const saveTokenForNewSubscription = async (token: string, userId: string) => {
  try {
    await axios.patch(`${ACCOUNT_DATA_ACCESS_URL}?id=${userId}`, {
      payment_token: token,
    });
  } catch (error) {
    // RETRY
    await axios.patch(`${ACCOUNT_DATA_ACCESS_URL}?id=${userId}`, {
      payment_token: token,
    });
    // TODO improve fault tolerent
  }
};

const handleSubscriptionRenewalNotification = async (data: JSObject) => {
  const token = data.token;
  const userId = data.custom_str1;
  if (data.payment_status != "COMPLETE") {
    console.log(
      `\n-------\nSUBSCRIPTION RENEWAL FAILED \nTOKEN = ${token} \nUSER_ID = ${userId}  \npf_payment_id = ${data.pf_payment_id}  \nTRANSACTION_STATUS = ${data.payment_status} .\n-------\n`
    );
    if (!token || !userId) {
      console.log(
        `\n-------\nINVALID TOKEN or USER_ID \nTOKEN = ${token} \nUSER_ID = ${userId} .\n-------\n`
      );
      return;
      // TODO notify admin something wrong.
    }
    try {
      // await axios.patch(`${ACCOUNT_DATA_ACCESS_URL}?id=${userId}`, {
      //   account_status: "SUSPENDED_FOR_UNPAID",
      // });
      // TODO send mail
    } catch {
      // RETRY
      // await axios.patch(`${ACCOUNT_DATA_ACCESS_URL}?id=${userId}`, {
      //   account_status: "SUSPENDED_FOR_UNPAID",
      // });
      // TODO improve fault tolerent
    }
  } else {
    console.log(
      `\n-------\nSUBSCRIPTION RENEWAL SUCCESSFULL \nTOKEN = ${token} \nUSER_ID = ${userId}  \npf_payment_id = ${
        data.pf_payment_id
      }  \nTRANSACTION_STATUS = ${
        data.payment_status
      } \n\nALL_DATA = ${JSON.stringify(data)} \n-------\n`
    );
  }
};

// ########################## TOKEN PAYMENT ########################### //

export const makePayfastTokenPayment = async (data: JSObject) => {
  const url = eval("`" + TOKEN_PAYMENT_URL + "`");
  const paymentDate = new Date().toISOString();
  const header = {
    "merchant-id": MARCHANT_ID,
    version: "v1",
    timestamp: paymentDate
  };
  const body: JSObject = {
    amount: data.payment.amount * 100, // convert to cents (required by the payfast API).
    item_name: data.item_name || "Trip payment",
    itn: "false",
  };
  const serializedSortedData = new URLSearchParams({
    ...header,
    ...body,
    passphrase: PASSPHRASE,
  });
  serializedSortedData.sort();
  header["signature"] = md5Hash(serializedSortedData.toString());
  let paymentSuccessfull = false;
  let payfastPaymentId = 0;
  try {
    const response = await axios.post(url, body, { headers: header });
    if (response.data.status == "success") {
      paymentSuccessfull = true;
      payfastPaymentId = response.data.data.pf_payment_id;
      const payment = {
        ...data.payment,
        date_time: paymentDate,
        payment_gateway_transaction_id: payfastPaymentId,
        payment_type : data.payment.payment_type || "CARD"
      };
      const result = await axios.post(`${DATA_ACCESS_SERVER_URL}/payment`, payment);
      return {
        status: "success",
        payment_id: result.data.data
      };
    } else {
      // TODO send mail. (check first if it's better to send the email only the driver manualy report)
      return {
        status: "failed",
        message: response.data.data.message
      }
    }
  } catch (error) {
    // TODO improve fault tolerance and error handling (maybe report)
    if(paymentSuccessfull){
      throw new functions.https.HttpsError("unknown", "unable_to_create_payment", {payment_date: paymentDate, payment_gateway_transaction_id: payfastPaymentId});
    }else {
      throw new functions.https.HttpsError("unknown", "payment_failed");
    }
  }
};
