/**
 *            INPORTANT!
 * Must be obfuscated before putting into prod
 * 
*/

import { initializeApp } from "firebase/app";

const firebaseConfig = {
  apiKey: "AIzaSyAbLts73IVYsQCHv7fxJtlmUvlXbuy9FO8",
  authDomain: "hamba-project.firebaseapp.com",
  databaseURL: "https://hamba-project-default-rtdb.firebaseio.com",
  projectId: "hamba-project",
  storageBucket: "hamba-project.appspot.com",
  messagingSenderId: "211386480430",
  appId: "1:211386480430:web:9c8153a436c8676eccacbf",
};

const app = initializeApp(firebaseConfig);