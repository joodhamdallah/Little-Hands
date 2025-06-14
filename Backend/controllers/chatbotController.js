const axios = require('axios');

exports.askGemini = async (req, res) => {
  const { message } = req.body;
  if (!message) {
    return res.status(400).json({ status: false, message: "Message is required" });
  }

  try {
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
       contents: [
  {
    parts: [
      {
        text: `أنت مساعد داخل تطبيق Little Hands،   وهو تطبيق عربي مخصص لمساعدة الأهل على رعاية الأطفال، حجز جلسات مع جليسات أطفال، خبراء سلوك، معلمي ظل، وغيرهم. اذا واجه المستخدم مشكلة معينة في التطبيق يمكنه استخدام الدعم الفني عن الطريث الذهاب الى الصفحة الرئيسية ثم على تواصل معنا وتقديم شكوى ليعبئ النموذج اذا اراد ان يقوم بالغاء الحجز عليه ان يقوم بذلك قبل 24 ساعة عن طريق التطبيق أجب دائمًا وكأنك جزء من هذا التطبيق.`
      },
      { text: message }
    ]
  }
]

      },
      {
        headers: { "Content-Type": "application/json" }
      }
    );

    const botReply = response.data?.candidates?.[0]?.content?.parts?.[0]?.text || "لم أتمكن من فهم السؤال.";
    return res.status(200).json({ status: true, reply: botReply });

  } catch (err) {
    console.error("Gemini API Error:", err?.response?.data || err.message);
    return res.status(500).json({ status: false, message: "خطأ في الاتصال بـ Gemini" });
  }
};
