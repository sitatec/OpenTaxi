import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import {
  getAndSaveTokenFromNewSubscription,
  getPayFastPaymentUrl as getPayFastPaymentURL,
  TransactionNotificationType,
} from "./payment";
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

// ###### TRANSACTION NOTIFICATION ###### //
export const receiveNotification = functions.https.onRequest(
  async (req, res) => {
    // TODO add further security check.
    try {
      const requestData = req.body;
      const notificationType = requestData.custom_int1;
      if (notificationType == TransactionNotificationType.NEW_SUBSCRIPTION) {
        await getAndSaveTokenFromNewSubscription(requestData);
      } else if (
        notificationType ==
        TransactionNotificationType.DRIVER_SUBSCRIPTION_RENEWAL
      ) {
        // TODO
      }
    } catch (e) {
      //TODO
    } finally {
      res.status(200).send();
    }
  }
);
// TODO check subscription status && make token payment.
