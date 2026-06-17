
const normalizeArabic = (str) => {
  if (!str) return '';
  return str
    .replace(/[\u064B-\u0652]/g, '') // Remove diacritics
    .replace(/[أإآ]/g, 'ا')
    .replace(/[ةـ]/g, 'ه') 
    .replace(/[ىي]/g, 'ي')
    .replace(/ئ/g, 'ي')
    .replace(/ؤ/g, 'و')
    .replace(/[ذز]/g, 'ز') 
    .replace(/[ضظ]/g, 'ض') 
    .toLowerCase()
    .trim();
};

const testCases = [
  { input: "أحمد", expected: "احمد" },
  { input: "مَدينة", expected: "مدينه" },
  { input: "سباك", expected: "سباك" },
  { input: "ذكي", expected: "زكي" },
  { input: "ضابط", expected: "ضابط" },
  { input: "ظابط", expected: "ضابط" },
];

testCases.forEach(tc => {
  const result = normalizeArabic(tc.input);
  console.log(`Input: ${tc.input} | Expected: ${tc.expected} | Result: ${result} | ${result === tc.expected ? '✅' : '❌'}`);
});
