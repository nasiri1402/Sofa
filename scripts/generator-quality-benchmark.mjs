import fs from "node:fs/promises";
import path from "node:path";

const scenarios = [
  {
    category: "money",
    focus: "Pay off debt",
    target: "Pay $600 toward credit-card debt this month and build a repeatable payoff routine",
    currentState: "Take-home income is $2,400/month, fixed expenses are $1,650, minimum debt payment is $120",
    preferences: "No new credit and no paid financial tools; I can spend 30 minutes every Sunday",
    idea: "Pay $600 toward credit-card debt this month without taking new credit",
    startPoint: "Income $2,400/month, fixed expenses $1,650, minimum payment $120",
    goals: ["money"],
    money: 3000,
  },
  {
    category: "content",
    focus: "YouTube",
    target: "Publish 4 useful product-design videos and 8 Shorts this month while growing beyond 120 subscribers",
    currentState: "The channel has 120 subscribers, 8 videos, and I can publish one long video plus two Shorts weekly",
    preferences: "No paid ads; film on an iPhone and edit in CapCut",
    idea: "Grow a product-design YouTube channel to 1,000 subscribers",
    startPoint: "120 subscribers, 8 videos, one long video and two Shorts available per week",
    goals: ["subscribers"],
    subscribers: 150,
  },
  {
    category: "business",
    focus: "Launch from zero",
    target: "Launch an online T-shirt store for amateur runners and test demand with the first 3 paid orders this month",
    currentState: "I have three designs but no store, audience, or supplier",
    preferences: "Maximum test budget is $1,000; start with print-on-demand and sell in the US",
    idea: "Launch a print-on-demand T-shirt store for amateur runners",
    startPoint: "Three designs, no store, no audience, no supplier",
    goals: ["clients", "money"],
  },
  {
    category: "learning",
    focus: "English",
    target: "Complete four speaking sessions this month and speak for 5 minutes with fewer pauses",
    currentState: "I understand simple text but freeze in conversation; I can study 45 minutes on weekdays",
    preferences: "Use free resources and include one speaking session every week",
    idea: "Build a consistent English speaking routine and complete four speaking sessions this month",
    startPoint: "A2 reading, weak speaking, 45 minutes on weekdays",
    goals: ["experience"],
  },
  {
    category: "health",
    focus: "Gym and training",
    target: "Establish a safe twice-weekly movement routine this month without worsening lower-back discomfort",
    currentState: "Desk job, no regular training, discomfort increases after long sitting; no diagnosis",
    preferences: "Home exercises only; stop anything that increases pain and include professional-care checkpoints",
    idea: "Build a safe twice-weekly routine around recurring lower-back discomfort",
    startPoint: "Desk job, no regular training, discomfort after prolonged sitting",
    goals: ["option"],
  },
  {
    category: "creativity",
    focus: "Design",
    target: "Finish and publish four polished mobile UI portfolio screens this month",
    currentState: "I know basic Figma and have two unfinished app screens",
    preferences: "Work 60 minutes on weekdays; use Figma and free feedback communities",
    idea: "Create and publish four polished mobile UI portfolio screens this month",
    startPoint: "Basic Figma skills and two unfinished app screens",
    goals: ["cases", "experience"],
  },
  {
    category: "career",
    focus: "Find a job",
    target: "Send 20 tailored applications this month and build a pipeline for remote junior product designer interviews",
    currentState: "One year of freelance experience, an outdated resume, and three portfolio cases",
    preferences: "Apply to English-speaking companies; 8 hours per week available",
    idea: "Get a remote junior product designer job paying at least $2,500/month",
    startPoint: "One year freelance, outdated resume, three portfolio cases",
    goals: ["clients", "money"],
  },
  {
    category: "it_product",
    focus: "Product",
    target: "Build a testable habit-tracker iOS MVP and invite the first 5 beta users this month",
    currentState: "I know basic SwiftUI, have wireframes, but have never shipped an app",
    preferences: "Solo project, Firebase free tier, 10 hours per week",
    idea: "Ship a SwiftUI habit-tracker MVP and invite the first 5 beta users this month",
    startPoint: "Basic SwiftUI, wireframes ready, no shipped apps",
    goals: ["clients", "experience"],
  },
  {
    category: "productivity",
    focus: "Focus",
    target: "Complete 90 minutes of distraction-free work on 5 weekdays for 30 days",
    currentState: "I average 25 minutes before checking messages and miss afternoon sessions",
    preferences: "No paid apps; mornings are available from 8:00 to 10:00",
    idea: "Build a 90-minute weekday deep-work routine",
    startPoint: "25-minute focus limit and frequent message checking",
    goals: ["experience"],
  },
];

function argument(name, fallback) {
  const index = process.argv.indexOf(name);
  return index === -1 ? fallback : process.argv[index + 1];
}

function extractPrompt(source) {
  const match = source.match(
    /private func makeSystemContent\(\) -> String \{[\s\S]*?"""\n([\s\S]*?)\n\s*"""\n/,
  );
  if (!match) throw new Error("Could not extract makeSystemContent prompt");

  const today = new Intl.DateTimeFormat("en-GB").format(new Date()).replaceAll("/", ".");
  return match[1]
    .replaceAll(/^ {8}/gm, "")
    .replaceAll("\\(dateFormatter.string(from: Date()))", today);
}

function makeInput(scenario, isCurrentPrompt) {
  const profile = {
    name: "QA User",
    age: "30",
    gender: "other",
    country_code: "US",
    currency_code: "USD",
  };

  if (isCurrentPrompt) {
    return {
      profile,
      brief: {
        category: scenario.category,
        focus: scenario.focus,
        target: scenario.target,
        current_state: scenario.currentState,
        preferences: scenario.preferences,
        timeframe: "1_month",
        difficulty: "medium",
      },
      response_language_code: "en",
    };
  }

  return {
    profile,
    brief: {
      idea: scenario.idea,
      timeframe: "1_month",
      experience: "intermediate",
      difficulty: "medium",
      start_point: scenario.startPoint,
      result: {
        goals: scenario.goals,
        money: scenario.money,
        subscribers: scenario.subscribers,
      },
      budget: scenario.category === "business" ? 1000 : undefined,
      limits: scenario.preferences,
    },
    response_language_code: "en-US",
  };
}

function outputText(response) {
  for (const output of response.output ?? []) {
    for (const content of output.content ?? []) {
      if (content.type === "output_text" && content.text) return content.text;
    }
  }
  throw new Error("OpenAI response did not contain output_text");
}

function metrics(plan) {
  const weeks = plan.plan?.weeks ?? [];
  const steps = weeks.flatMap((week) => week.steps ?? []).map((step) => step.title);
  const vaguePattern = /^(create a plan|improve|work on|track progress|learn about)\b/i;
  const lengths = steps.map((step) => step.length);
  const average = lengths.length
    ? Math.round(lengths.reduce((sum, value) => sum + value, 0) / lengths.length)
    : 0;

  return {
    weekCount: weeks.length,
    stepCount: steps.length,
    averageStepCharacters: average,
    minimumStepCharacters: lengths.length ? Math.min(...lengths) : 0,
    maximumStepCharacters: lengths.length ? Math.max(...lengths) : 0,
    detailedStepShare: steps.length
      ? Number((steps.filter((step) => step.length >= 90).length / steps.length).toFixed(2))
      : 0,
    vagueOpeningCount: steps.filter((step) => vaguePattern.test(step)).length,
    inventedToolOrFileCount: steps.filter(
      (step) => /\.(csv|xlsx|txt|fig)\b|in the app (calendar|journal|ledger)|habit tracker/i.test(step),
    ).length,
  };
}

async function generate(apiKey, prompt, scenario, isCurrentPrompt) {
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: "gpt-5-nano",
      input: [
        {
          role: "system",
          content: [{type: "input_text", text: prompt}],
        },
        {
          role: "user",
          content: [{
            type: "input_text",
            text: JSON.stringify(makeInput(scenario, isCurrentPrompt)),
          }],
        },
      ],
      max_output_tokens: 10000,
      reasoning: {effort: "low"},
      text: {format: {type: "json_object"}},
    }),
  });

  const raw = await response.text();
  if (!response.ok) {
    throw new Error(`OpenAI ${response.status}: ${raw.slice(0, 500)}`);
  }
  const envelope = JSON.parse(raw);
  const plan = JSON.parse(outputText(envelope));
  return {plan, metrics: metrics(plan), responseId: envelope.id};
}

const swiftFile = path.resolve(argument("--swift-file", "Sofa/Services/ProjectGenerator/ProjectGenerator.swift"));
const outputFile = path.resolve(argument("--output", "generator-quality-results.json"));
const label = argument("--label", "current");
const selectedCategories = argument("--categories", "")
  .split(",")
  .map((category) => category.trim())
  .filter(Boolean);
const apiKey = process.env.OPENAI_API_KEY;
if (!apiKey) throw new Error("OPENAI_API_KEY is required");

const source = await fs.readFile(swiftFile, "utf8");
const prompt = extractPrompt(source);
const isCurrentPrompt = prompt.includes('"category"');
const results = [];

for (const scenario of scenarios.filter(
  (candidate) => !selectedCategories.length || selectedCategories.includes(candidate.category),
)) {
  process.stdout.write(`Generating ${label}/${scenario.category}... `);
  const result = await generate(apiKey, prompt, scenario, isCurrentPrompt);
  results.push({category: scenario.category, ...result});
  console.log(`${result.metrics.stepCount} steps, avg ${result.metrics.averageStepCharacters} chars`);
}

await fs.writeFile(
  outputFile,
  JSON.stringify({label, model: "gpt-5-nano", generatedAt: new Date().toISOString(), results}, null, 2),
);
console.log(`Saved ${outputFile}`);
