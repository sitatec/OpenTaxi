import { JSObject } from "./type_alias";
import { createTransport, Transporter } from "nodemailer";
import * as SMTPTransport from "nodemailer/lib/smtp-transport";

const SMTP_URL = "smtpout.secureserver.net";
const SMTP_PORT = 465;
const SOURCE_EMAIL = "no-reply@hambaza.co.za";
const PASSWORD = "EatYourFruit@55";

let transporter: Transporter<SMTPTransport.SentMessageInfo>;

export const sendEmailInternal = async (data: JSObject) => {
  if (!transporter) {
    transporter = createTransport({
      host: SMTP_URL,
      port: SMTP_PORT,
      secure: SMTP_PORT == 465,
      auth: {
        user: SOURCE_EMAIL,
        pass: PASSWORD,
      },
    });
  }

  await transporter.sendMail({
    from: `"Hamba Services" <${SOURCE_EMAIL}>`, // sender address
    to: data.recipients,
    subject: data.subject,
    text: data.content.text,
    html: data.content.html
  });
};
