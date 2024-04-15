const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();


exports.addMatchingNotification = functions.firestore.document('matchingNotifications/{notiID}').onCreate(async (snap, context) => {
  const title = snap.data().title;
  const body = snap.data().body;
  const userId = snap.data().machedUserId;

  const getDeviceTokensPromise = db.collection("deviceTokens").where("userId", "==", userId).get();

  const result = await Promise.all([getDeviceTokensPromise]);
  const tokens = result[0].docs.map(doc => doc.data().deviceToken);

  const payload = {
    notification: {
      title: title,
      body: body,
      sound: "default",
    },
    data: {
      type: "notification",
    }
  };

  // Send notifications to all tokens.
  const response = await admin.messaging().sendToDevice(tokens, payload);
  response.results.forEach((result, index) => {
    const error = result.error;
    if (error) {
      functions.logger.error(
        'Failure sending notification to',
        tokens[index],
        error
      );
    }
  });

  return Promise.resolve();
});



exports.messageNotification = functions.firestore.document('matches/{matchId}/chat/{chatId}').onCreate(async (snap, context) => {

  const userIds = await db.collection("matches").doc(context.params.matchId).get().then(doc => {
    return doc.data().userIds;
  });

  console.log(userIds);

  const messageUserId = snap.data().userId;

  console.log(messageUserId);

  var receiverId = userIds.filter(function (item) {
    return item !== messageUserId;
  });

  console.log(receiverId);

  const getUser = db.collection("userProfile").doc(receiverId[0]).get();
  const getDeviceTokensPromise = db.collection("deviceTokens").where("userId", "==", receiverId[0]).get();

  const result = await Promise.all([getUser, getDeviceTokensPromise]);
  const user = result[0].data();
  const tokens = result[1].docs.map(doc => doc.data().deviceToken);

  const payload = {
    notification: {
      title: user.fullName,
      body: "You have a new message",
      sound: "default",
    },
    data: {
      type: "message",
      userId: messageUserId,
      matchId: context.params.matchId,
    }
  };

  // Send notifications to all tokens.
  const response = await admin.messaging().sendToDevice(tokens, payload);
  response.results.forEach((result, index) => {
    const error = result.error;
    if (error) {
      functions.logger.error(
        'Failure sending notification to',
        tokens[index],
        error
      );
    }
  });

  return Promise.resolve();
});