import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import {
  receiveTransationNotification,
  getPayFastPaymentUrl,
  makePayfastTokenPayment,
} from "./payment";
import { ACCOUNT_DATA_ACCESS_URL, SERVERS_ACCESS_TOKEN } from "./constants";
import {
  sendDriverSubscriptionFailedEmailInternal,
  sendEmailInternal,
  sendRiderPaymentFailedEmailInternal,
} from "./email";

axios.defaults.headers.common[
  "Authorization"
] = `Bearer ${SERVERS_ACCESS_TOKEN}`;

// TODO add authentication step to all functions invocation.

// ---------------------- NODIFICATION -------------------- //

export const sendNotification = functions.https.onCall(
  async (notification, _) => {
    const recipientToken = await _getUserToken(notification["to"]);
    delete notification.to;
    await admin.messaging().sendToDevice(recipientToken, notification);
  }
);

const _getUserToken = async (userId: string) => {
  const response = await axios.get(
    `${ACCOUNT_DATA_ACCESS_URL}/notification_token?account_id=${userId}`
  );
  return response.data.notification_token;
};

// ---------------------- PAYMENT -------------------- //

// ###### GET URL ###### //
export const getPaymentURL = functions.https.onCall((paymentData, _) =>
  getPayFastPaymentUrl(paymentData)
);

// ###### TRANSACTION NOTIFICATION ###### //
export const receiveNotification = functions.https.onRequest(
  async (req, res) => {
    // TODO add further security check.
    try {
      const requestData = req.body;
      await receiveTransationNotification(requestData);
    } catch (e) {
      //TODO
    } finally {
      res.status(200).send();
    }
  }
);
// TODO check subscription status

export const makeTokenPayment = functions.https.onCall(
  makePayfastTokenPayment
);

// ---------------------- EMAIL -------------------- //

export const sendEmail = functions.https.onCall(sendEmailInternal);

export const sendDriverSubscriptionFailedEmail = functions.https.onCall(
  sendDriverSubscriptionFailedEmailInternal
);

export const sendRiderPaymentFailedEmail = functions.https.onCall(
  sendRiderPaymentFailedEmailInternal
);
