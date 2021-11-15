import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

const sendNotification = functions.https.onCall(async (data, _) => {
  const recipientToken = await _getUserToken(data["to"]);
  delete data.to;
  await admin.messaging().sendToDevice(recipientToken, data["notification"]);
});

const _getUserToken = async (userId: string) => {
  const response = await axios.get(
    `url/notification_token?account_id=${userId}`
  );
  return response.data.notification_token;
};