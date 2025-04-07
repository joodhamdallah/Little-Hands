module.exports = function getVerificationEmailTemplate(verificationURL) {
    return `
      <div style="font-family: sans-serif; padding: 20px; background-color: #f8f8f8; text-align: center; color: #333;">
  
        <h2 style="color: #ff4081;">Confirm your email</h2>
        <p style="font-size: 16px;">
          Great work on setting up your Little Hands account.<br>
          Now, we need to verify your email to make sure it's really you.
        </p>
  
        <a href="${verificationURL}"
           style="
             display: inline-block;
             margin: 20px 0;
             padding: 12px 24px;
             background-color: #ff4081;
             color: white;
             text-decoration: none;
             border-radius: 6px;
             font-weight: bold;">
          VERIFY NOW
        </a>
  
        <p style="font-size: 14px; margin-top: 30px;">
          This link will expire in 10 minutes.<br>
          If the button doesn't work, copy and paste this URL into your browser:<br>
          <a href="${verificationURL}">${verificationURL}</a>
        </p>
  
        <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">
  
        <div style="font-size: 12px; color: #888;">
          &copy; ${new Date().getFullYear()} Little Hands — All rights reserved.
        </div>
      </div>
    `;
  };
  