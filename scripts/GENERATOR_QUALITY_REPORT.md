# Generator quality audit

## Scope

- Compared the original pre-onboarding generator prompt with the current second-onboarding prompt.
- Exercised all nine categories with realistic one-month briefs against the production model (`gpt-5-nano`).
- Checked detail, actionability, mobile text length, language consistency, external-outcome honesty, health safety, and invented Sofa capabilities.

## Root cause

The updated onboarding prompt had reduced each week to 3-5 steps, limited each step to 82 characters, and stopped passing the selected difficulty to the API. This made generated plans shorter and more generic than the original implementation.

## Before and after

| Metric | Original aligned prompt | Improved prompt |
| --- | ---: | ---: |
| Categories tested | 9 | 9 |
| Total generated steps | 188 | 168 |
| Average characters per step | 93 | 111 |
| Detailed steps (90+ characters) | 55% | 83% |
| Generic step openings | 0 | 0 |
| Invented Sofa tools/files | 0 | 0 |

The final targeted checks produced 100% detailed steps for content, business, and the health safety case, with average step lengths between 106 and 122 characters. Career averaged 109 characters with 85% detailed steps.

## Changes

- Restored difficulty (`easy`, `medium`, `hard`) as an explicit generator input.
- Increased weekly depth to 4-6 steps while retaining 4, 12, or 24 weeks for the selected deadline.
- Required every step to contain a concrete action, execution detail, and observable completion criterion.
- Added category-specific planning rules for all nine onboarding topics.
- Added strict rules against mixed languages, fabricated Sofa tools, fake files, and guaranteed third-party outcomes.
- Added a health override for pain, injury, recurring symptoms, or an undiagnosed condition.
- Added repeatable contract and live-generation benchmark scripts.

## Remaining model behavior

Generation is probabilistic. The prompt now explicitly rejects unsafe health prescriptions and assumed external results, but future model-output monitoring should continue. A server-side semantic validator and one correction retry would be the next reliability layer if production logs show recurring violations.
