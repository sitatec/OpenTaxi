import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import { getPayFastPaymentUrl as getPayFastPaymentURL } from "./payment";

// ---------------------- NODIFICATION -------------------- //

export const sendNotification = functions.https.onCall(async (notification, _) => {
  const recipientToken = await _getUserToken(notification["to"]);
  delete notification.to;
  await admin.messaging().sendToDevice(recipientToken, notification);
});

const _getUserToken = async (userId: string) => {
  const response = await axios.get(
    `url/notification_token?account_id=${userId}`
  );
  return response.data.notification_token;
};


// ---------------------- PAYMENT -------------------- //

export const getPaymentURL = functions.https.onCall((paymentData, _) =>
  getPayFastPaymentURL(paymentData)
);
