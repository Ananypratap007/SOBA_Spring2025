const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: functions.config().gmail.email,
    pass: functions.config().gmail.password,
  },
});

exports.sendVerificationEmail = functions.https.onCall(async (data, context) => {
  const mailOptions = {
    from: 'Your App <noreply@yourapp.com>',
    to: data.email,
    subject: 'Your Verification Code',
    text: `Your verification code is: ${data.code}\nThis code will expire in 15 minutes.`,
  };

  await transporter.sendMail(mailOptions);
  return { success: true };
});