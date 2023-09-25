/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require('firebase-admin');
const serviceAccount = require("./service_account.json");


admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: `https://${serviceAccount.project_id}-default-rtdb.firebaseio.com`
});


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.dataPreProcessing = functions.database
  .ref("/measurement_history/Devices/0420/{timestamp}")
  .onCreate((snapshot, context) => {

    const timestamp = parseInt(context.params.timestamp);
    console.info(`New data is added: ${timestamp}`);

    let dateObject =new Date(timestamp * 1000);

    const logsData = snapshot.val();
    let date = getDateTimeWithTimezone(dateObject).split(" ")[0];;
    let datetime = getDateTimeWithTimezone(dateObject);

    let temp = parseFloat(logsData.Temperature);
    let waterTemp = parseFloat(logsData.WaterTemperature);
    let humid = parseFloat(logsData.Humidity);
    let tds = parseFloat(logsData.TotalDissolvedSolids);
    let ph = parseFloat(logsData.pH);

    if (temp && waterTemp && humid && tds && ph) {
      console.log("All values are valid");
      processDailyData("Temperature", temp, date);
      processDailyData("WaterTemperature", waterTemp, date);
      processDailyData("Humidity", humid, date);
      processDailyData("TotalDissolvedSolids", tds, date);
      processDailyData("pH", ph, date);

      processHourlyData("Temperature", temp, datetime);
      processHourlyData("WaterTemperature", waterTemp, datetime);
      processHourlyData("Humidity", humid, datetime);
      processHourlyData("TotalDissolvedSolids", tds, datetime);
      processHourlyData("pH", ph, datetime);
    }else {
      console.log("Has an invalid input...all values are skipped.");
    }
});


function processDailyData(type, value, id) {
  const dailyData = admin.database().ref(`/DailyData/${type}`);
  const dailyStamp = Date.parse(id) / 1000;
  admin
    .database()
    .ref(`/DailyData/${type}/${id}`)
    .once('value')
    .then(data => {
      if (data.hasChildren()) {
        let currentData = data.val();
        console.log(currentData);
        dailyData
          .child(id)
          .set(processData(currentData, value))
      } else {
        dailyData.child(id).set({
          "timestamp": dailyStamp,
          "current_value": value,
          "total_value": value,
          "min": value,
          "max": value,
          "count": 1
        });
      }
    })
}

function processHourlyData(type, value, id) {
  const hourlyData = admin.database().ref(`/HourlyData/${type}`);
  const hourlyStamp = Date.parse(id) / 1000;
  admin
    .database()
    .ref(`/HourlyData/${type}/${id}`)
    .once('value')
    .then(data => {
      console.log("Data");
      if (data.hasChildren()) {
        let currentData = data.val();
        console.log(currentData);
        hourlyData
          .child(id)
          .set(processData(currentData, value))
      } else {
        hourlyData.child(id).set({
          "timestamp": hourlyStamp,
          "current_value" : value,
          "total_value": value,
          "min": value,
          "max": value,
          "count": 1
        });
      }
    })
}

function getDateTimeWithTimezone(dateValue) {
  let dateString = dateValue.toLocaleString('en-PH', {
    timeZone: 'Asia/Manila',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hourCycle: "h23"
  });
  let temp = dateString.replaceAll("/","-").replace(",", "");
  return changeDateTimeFormat(temp);
}

function changeDateTimeFormat(value) {
  let datehr =value.split(":");
  return `${datehr[0]}:00`;
}


function processData(currentData, newData) {
  currentData.current_value = newData;
  currentData.total_value += newData;
  if (currentData.min > newData) {
    currentData.min = newData;
  }
  if (currentData.max < newData) {
    currentData.max = newData;
  }
  currentData.count++;

  return currentData;
}

function getDate(value) {
  return `${value.getMonth() + 1}-${value.getDate()}-${value.getFullYear()}`;
}

function getDateWithHour (value) {
  const hour = `${value.getHours()}:00`
  const [sHours, minutes] = hour.match(/([0-9]{1,2}):([0-9]{2})/).slice(1);
  const period = +sHours < 12 ? 'AM' : 'PM';
  const hours = +sHours % 12 || 12;

  return `${value.getMonth() + 1}-${value.getDate()}-${value.getFullYear()} ${hours}:${minutes} ${period}`;
}

function getTimestamp(value) {
  return
}

//updateDeviceStatus function

let lastDataTimestamp = 0; // Initialize the timestamp of the last data

const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

exports.checkDeviceData = functions.pubsub.schedule('every 10 seconds').timeZone('UTC').onRun((context) => {
  const currentTime = Date.now();
  const tenSecondsAgo = currentTime - 10000; // 10 seconds ago

  // Reference to the "/measurement_history/Devices/0420" path
  const devicesRef = admin.database().ref("/measurement_history/Devices/0420");

  // Query data within the last 10 seconds
  return devicesRef.orderByKey().startAt(tenSecondsAgo.toString()).once("value")
    .then(snapshot => {
      const hasData = snapshot.exists();

      // Set the "hasData" node in Firebase
      return admin.database().ref('/device_status/hasData').set(hasData);
    })
    .catch(error => {
      console.error("Error checking device data:", error);
      return null;
    });
});
