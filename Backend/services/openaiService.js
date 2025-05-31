const axios = require('axios');
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

const GEMINI_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

async function summarizePDF(text) {
  const prompt = `اقرأ النص التالي واستخرج منه:
1. عنوانًا قصيرًا باللغة العربية.
2. ملخصًا بسيطًا من جملة أو جملتين مناسب  .

النص:
"""${text}"""`;

  try {
    const response = await axios.post(
      `${GEMINI_URL}?key=${GEMINI_API_KEY}`,
      {
        contents: [
          {
            parts: [{ text: prompt }]
          }
        ]
      }
    );

    const raw = response.data.candidates?.[0]?.content?.parts?.[0]?.text || '';

    // ✅ معالجة العنوان والملخص
    let title = 'عنوان غير متوفر';
    let summary = 'لم نتمكن من تلخيص النص.';

    // محاولة فصل العنوان والملخص بشكل ذكي
    const titleMatch = raw.match(/(?:عنوان\s*(?:قصير)?[:\-]?)\s*(.*)/i);
    const summaryMatch = raw.match(/(?:ملخص[:\-]?)\s*(.*)/is);

    if (titleMatch && titleMatch[1].length > 3) {
      title = titleMatch[1].trim().replace(/^\*\*/, '').replace(/\*\*$/, '');
    }

    if (summaryMatch && summaryMatch[1].length > 10) {
      summary = summaryMatch[1].trim().replace(/^\*\*/, '').replace(/\*\*$/, '');
    }

    // fallback: إذا لم يتمكن من استخراجهم بشكل صحيح
    if (title === 'عنوان غير متوفر' && summary === 'لم نتمكن من تلخيص النص.') {
      const lines = raw.trim().split('\n').filter(Boolean);
      if (lines.length >= 2) {
        title = lines[0].trim();
        summary = lines.slice(1).join(' ');
      }
    }

    return { title, summary };

  } catch (err) {
    console.error("❌ Gemini Error:", err.response?.data || err.message);
    return {
      title: 'عنوان غير متوفر',
      summary: 'لم نتمكن من تلخيص النص. الرجاء المحاولة لاحقًا.',
    };
  }
}

module.exports = { summarizePDF };
