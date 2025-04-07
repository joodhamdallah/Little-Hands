const nodemailer = require("nodemailer");
require("dotenv").config();

async function sendEmail({ to, subject, html }) {
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  await transporter.sendMail({
    from: '"Little Hands 👶🏻" <noreply@littlehands.app>',
    to,
    subject,
    html,
  });
}

module.exports = sendEmail;
