// utils/firebase.js
const admin = require("firebase-admin");
const serviceAccount = require("../firebase/firebase-config.json"); 
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
