function getParentBookingConfirmedEmail(date, time, caregiverName) {
  return `
  <div dir="rtl" style="direction: rtl; text-align: right; font-family: 'Tahoma', sans-serif; color: #333; max-width: 600px; margin: auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden;">
    <div style="background-color: #FF600A; color: #fff; padding: 16px; text-align: center;">
      <h2 style="margin: 0;">✅ تم تأكيد الحجز</h2>
    </div>
    <div style="padding: 24px;">
      <p style="font-size: 16px;">عزيزي ولي الأمر،</p>
      <p style="font-size: 16px;">تم تأكيد حجز جلستك بنجاح مع <strong>${caregiverName}</strong>.</p>
      <table style="width: 100%; margin-top: 20px; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px; font-weight: bold; background: #f9f9f9;">📅 التاريخ:</td>
          <td style="padding: 8px;">${date}</td>
        </tr>
        <tr>
          <td style="padding: 8px; font-weight: bold; background: #f9f9f9;">⏰ الوقت:</td>
          <td style="padding: 8px;">${time}</td>
        </tr>
      </table>
      <p style="margin-top: 24px; font-size: 15px;">نتمنى لك تجربة رائعة مع <strong style="color: #FF600A;">Little Hands</strong>!</p>
    </div>
  </div>
  `;
}

function getCaregiverBookingConfirmedEmail(date, time, parentName) {
  return `
  <div dir="rtl" style="direction: rtl; text-align: right; font-family: 'Tahoma', sans-serif; color: #333; max-width: 600px; margin: auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden;">
    <div style="background-color: #FF600A; color: #fff; padding: 16px; text-align: center;">
      <h2 style="margin: 0;">💰 تم تأكيد الجلسة</h2>
    </div>
    <div style="padding: 24px;">
      <p style="font-size: 16px;">عزيزي مقدم الرعاية،</p>
      <p style="font-size: 16px;">تم تأكيد الجلسة من قبل ولي الأمر <strong>${parentName}</strong>.</p>
      <table style="width: 100%; margin-top: 20px; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px; font-weight: bold; background: #f9f9f9;">📅 التاريخ:</td>
          <td style="padding: 8px;">${date}</td>
        </tr>
        <tr>
          <td style="padding: 8px; font-weight: bold; background: #f9f9f9;">⏰ الوقت:</td>
          <td style="padding: 8px;">${time}</td>
        </tr>
      </table>
      <p style="margin-top: 24px; font-size: 15px;">شكراً لانضمامك إلى <strong style="color: #FF600A;">Little Hands</strong>!</p>
    </div>
  </div>
  `;
}

module.exports = {
  getParentBookingConfirmedEmail,
  getCaregiverBookingConfirmedEmail,
};
