/**
 *            INPORTANT!
 * Must be obfuscated before putting into prod
 *
 */

import { initializeApp } from "firebase/app";
import { getAuth, RecaptchaVerifier, signInWithPhoneNumber } from "firebase/auth";
import { mainModal, showMainModal, hideMainModal } from "./modal";

initializeApp({
  apiKey: "AIzaSyAbLts73IVYsQCHv7fxJtlmUvlXbuy9FO8",
  authDomain: "hamba-project.firebaseapp.com",
  databaseURL: "https://hamba-project-default-rtdb.firebaseio.com",
  projectId: "hamba-project",
  storageBucket: "hamba-project.appspot.com",
  messagingSenderId: "211386480430",
  appId: "1:211386480430:web:9c8153a436c8676eccacbf",
});

const auth = getAuth();
auth.languageCode = "en";

const PHONE_NUMBER_LENGTH = 9;

const verifyPhoneNumberButtonId = "verify_phone_number";

const targetNode = document.getElementsByTagName("body")[0];

const config = { subtree: true, childList: true };

const domListenner = function (mutationsList, observer) {
  for (const mutation of mutationsList) {
    console.log(`--- MUTATION ${mutation} --`);
    if (mutation.type === "childList") {
      const iframe = document.getElementsByTagName("iframe")[0];
      console.log(`--- IFRAME ${iframe} --`);
      if (iframe) {
        observer.disconnect();
        iframe.addEventListener("load", function (_) {
          window.iframeDocument = iframe.contentDocument
          const button = window.iframeDocument.querySelector("#text_1209 p");
          console.log(`--- BUTTON ${button} --`);
          if (button) {
            button.id = verifyPhoneNumberButtonId;

            window.recaptchaVerifier = new RecaptchaVerifier(
              "recaptcha-container",
              {
                size: "invisible",
              },
              auth
            );

            window.recaptchaVerifier.render().then((widgetId) => {
              window.recaptchaWidgetId = widgetId;
            });

            button.onclick = verify;
          }
        });
      }
    }
  }
};

const observer = new MutationObserver(domListenner);

observer.observe(targetNode, config);

function verify(_) {
  console.log(`--------  verify - line 1 -----------`);
  const validPhoneNumber = getValidPhoneNumber();
  console.log(`--------  verify - afet getting phone number -----------`);
  if (validPhoneNumber) {
    const recaptchaVerifier = window.recaptchaVerifier;
    console.log(`-------- BEFORE signInWithPhoneNumber -----------`);
    signInWithPhoneNumber(auth, validPhoneNumber, recaptchaVerifier)
      .then((confirmationResult) => {
        // SMS sent. Prompt user to type the code from the message, then sign the
        // user in with confirmationResult.confirm(code).
        window.confirmationResult = confirmationResult;
        requestSentCode();
      })
      .catch((error) => {
        recaptchaVerifier
          .getAssertedRecaptcha()
          .reset(window.recaptchaWidgetId);
          console.error(`-------- ERROR => ${error} -----------`);
        // Error; SMS not sent
        //TODO
      });
  } else {
    //TODO
  }
}

function requestSentCode() {
  mainModal.getElementsByClassName("modal-content-body")[0].innerHTML = `
    <fieldset>
      <legend>2. Enter your 6-digit code:</legend>
      <div class="verify-btn-wrapper">
        <input type="text"
              pattern="\d*"
              name="code"
              size="6"
              autocomplete="off"
              aria-label="verification code"
              aria-required="true">
        <button type="submit" name="verify"> Verify </button>
        <span class="validation big ss-standard"></span>
        <span class="screen-reader-text" aria-live="polite"></span>
      </div>
    </fieldset>
  `;
  showMainModal();
}

function getValidPhoneNumber() {
  const phoneNumber = window.iframeDocument
    .getElementById("input_8_full")
    .value.replace(/\D/g, "");

  if (phoneNumber.length == PHONE_NUMBER_LENGTH) {
    return phoneNumber;
  }
}
