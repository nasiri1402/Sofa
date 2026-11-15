import assert from "node:assert/strict";
import fs from "node:fs";

const promptPath = "Sofa/Services/ProjectGenerator/ProjectGenerator.swift";
const requestPath = "Sofa/Services/FunctionsClient/Requests/GeneratorRequest.swift";
const prompt = fs.readFileSync(promptPath, "utf8");
const request = fs.readFileSync(requestPath, "utf8");

const categories = [
  "money",
  "content",
  "business",
  "learning",
  "health",
  "creativity",
  "career",
  "it_product",
  "productivity",
];

assert.doesNotMatch(prompt, /12_months/, "12-month plans must remain removed");
assert.match(prompt, /"difficulty": "<string, one of: 'easy' \| 'medium' \| 'hard'>"/);
assert.match(request, /let difficulty: String/);
assert.match(prompt, /each step title: normally 80-130 characters and never more than 145/);
assert.match(prompt, /Each week MUST contain 4-6 concrete action steps/);
assert.match(prompt, /observable output marks it complete/);
assert.match(prompt, /must not guarantee subscribers, views, sales/);
assert.match(prompt, /do not name exercises, stretches, repetitions, loads/);
assert.match(prompt, /DO NOT create a workout or rehabilitation routine/);
assert.match(prompt, /progress toward <target>/);
assert.match(prompt, /must not claim that pain improved, stayed stable, or did not worsen/);
assert.match(prompt, /Never claim that Sofa has a ledger, calendar, journal/);
assert.match(prompt, /Do not mix words from another language/);

for (const category of categories) {
  assert.match(prompt, new RegExp(`- ${category}:`), `Missing quality rule for ${category}`);
}

console.log("Generator prompt contract is valid.");
