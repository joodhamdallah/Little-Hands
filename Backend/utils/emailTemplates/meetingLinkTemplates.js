module.exports = {
  getParentMeetingEmail(meetingLink, meetingDate, meetingTime, babysitterName) {
    return `
      <div style="font-family: sans-serif; padding: 20px; background-color: #f9fbfc; text-align: center; color: #333;">

        <h2 style="color: #2b7a78;">📅 Your Meeting is Scheduled!</h2>
        <p style="font-size: 16px;">
          Hello! 👋<br>
          You have a scheduled meeting with babysitter <strong>${babysitterName}</strong> as part of your babysitting session.
        </p>

        <p style="font-size: 16px; margin: 20px 0;">
          <strong>Date:</strong> ${meetingDate} <br>
          <strong>Time:</strong> ${meetingTime}
        </p>

        <a href="${meetingLink}"
           style="
             display: inline-block;
             margin: 20px 0;
             padding: 12px 24px;
             background-color: #2b7a78;
             color: white;
             text-decoration: none;
             border-radius: 6px;
             font-weight: bold;">
          Join Meeting
        </a>

        <p style="font-size: 14px; margin-top: 30px;">
          If the button doesn’t work, you can copy this link:<br>
          <a href="${meetingLink}">${meetingLink}</a>
        </p>

        <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">

        <div style="font-size: 12px; color: #888;">
          &copy; ${new Date().getFullYear()} Little Hands — Helping parents with care and confidence.
        </div>
      </div>
    `;
  },

  getBabysitterMeetingEmail(meetingLink, meetingDate, meetingTime, parentName) {
    return `
      <div style="font-family: sans-serif; padding: 20px; background-color: #fff8f0; text-align: center; color: #333;">

        <h2 style="color: #e07a5f;">🎥 You Have a Meeting Coming Up!</h2>
        <p style="font-size: 16px;">
          Hi there! 🧡<br>
          You’re scheduled for a meeting with <strong>${parentName}</strong> to discuss the upcoming babysitting session.
        </p>

        <p style="font-size: 16px; margin: 20px 0;">
          <strong>Date:</strong> ${meetingDate} <br>
          <strong>Time:</strong> ${meetingTime}
        </p>

        <a href="${meetingLink}"
           style="
             display: inline-block;
             margin: 20px 0;
             padding: 12px 24px;
             background-color: #e07a5f;
             color: white;
             text-decoration: none;
             border-radius: 6px;
             font-weight: bold;">
          Join Meeting
        </a>

        <p style="font-size: 14px; margin-top: 30px;">
          If you can’t click the button, use this link:<br>
          <a href="${meetingLink}">${meetingLink}</a>
        </p>

        <hr style="margin: 40px 0; border: none; border-top: 1px solid #ddd;">

        <div style="font-size: 12px; color: #888;">
          &copy; ${new Date().getFullYear()} Little Hands — Thank you for being a trusted caregiver.
        </div>
      </div>
    `;
  }
};
