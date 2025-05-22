const axios = require('axios');

const OLLAMA_URL = 'http://localhost:11434/api/generate';

async function summarizePDF(text) {
const prompt = `Extract a short title and a one-sentence summary suitable for displaying in a mobile app card, based on the following text:\n\n${text}`;

  const response = await axios.post(OLLAMA_URL, {
    model: 'llama2:7b',
    prompt,
    stream: false
  });

  const raw = response.data.response;
  
  // Optional: split response into title + summary
  const [titleLine, ...summaryLines] = raw.split('\n').filter(Boolean);
  return {
    title: titleLine,
    summary: summaryLines.join(' ')
  };
}

module.exports = { summarizePDF };
