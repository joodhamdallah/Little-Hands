// utils/emailTemplates/resetPasswordTemplate.js

module.exports = function getResetPasswordEmailTemplate(resetURL) {
    return `
      <div style="background-color:#f8f8f8; padding:30px; font-family:sans-serif; color:#333; text-align:center;">
        
        <h2 style="color:#ff4081;">Reset your password</h2>
        <p style="font-size:16px; margin:20px 0;">
          We received a request to reset your Little Hands account password.<br>
          Click the button below to set a new one.
        </p>
  
        <a href="${resetURL}" 
           style="display:inline-block; padding:12px 24px; background-color:#ff4081; color:white; text-decoration:none; border-radius:8px; font-weight:bold;">
          RESET PASSWORD
        </a>
  
        <p style="margin-top:40px; font-size:14px;">Or copy and paste this link in your browser:<br>${resetURL}</p>
  
        <hr style="margin:30px 0; border-color:#ddd;" />
        <div style="font-size:12px; color:#aaa;">
          This link will expire in 10 minutes.<br>
          If you didn't request a password reset, you can safely ignore this email.
        </div>
      </div>
    `;
  }
  