import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import { getPayFastPaymentUrl as getPayFastPaymentURL } from "./payment";
import { DATA_ACCESS_SERVER_URL } from "./constants";

// TODO add authentication step to all functions.

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
    `${DATA_ACCESS_SERVER_URL}/account/notification_token?account_id=${userId}`
  );
  return response.data.notification_token;
};

// ---------------------- PAYMENT -------------------- //

// ###### GET URL ###### //
export const getPaymentURL = functions.https.onCall((paymentData, _) =>
  getPayFastPaymentURL(paymentData)
);

// ###### RECEIVE TOKEN ###### //
export const receivePaymentToken = functions.https.onRequest(
  async (req, res) => {
    // TODO add further security check.
    const requestData = req.body;
    if (requestData.payment_status != "COMPLETE" || !requestData.token) {
      res.status(200).send();
    }
    const token = requestData.token;
    const userId = requestData.custom_str1;
    try {
      await axios.patch(`${DATA_ACCESS_SERVER_URL}/account?id=${userId}`, {
        payment_token: token,
      });
    } catch (error) {
      // TODO improve fault tolerent
    } finally {
      res.status(200).send();
    }
  }
);
// TODO check subscription status && make token payment.