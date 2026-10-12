---
name: writing-flavor-review
description: Review awkward or AI-sounding prose for unsupported speculation, imagined rebuttals, self-justification, and redundancy, and suggest local edits. Use when the user requests this review, asks to remove AI-sounding wording, or requests a focused review of a model-written draft.
---

# Writing Flavor Review

Inspect expression problems in an article, explain them using the original text, and suggest revisions.

## Review requirements

Apply the same review standard to every article. Read the entire article and the user's requirements, then check each paragraph for the six issues below, covering titles, body text, tables, abstracts, and endings. For a series, also check repetition across articles. Evaluate the evidence, relevance, and expressive purpose of each paragraph in context, preserving useful information when editing.

1. **Unsupported speculation**: Introducing unsupported names, candidate implementations, or judgments, then withdrawing them with "cannot confirm." Remove irrelevant speculation; verify material that affects the central conclusion before handling it. Check whether abstracts and tables change the certainty of conclusions in the body.
2. **Invented corrections of the reader**: Assuming the reader holds a mistaken view, then correcting it with phrases such as "it is easy to misunderstand" or "this should not be understood as." State facts, conditions, and causality directly. Criticism or correction must have a real, specific target and context.
3. **Invented inferior alternatives**: Making up "crude" or "arbitrary" approaches to make the current one look better. Remove this framing. Comparisons must identify specific alternatives, actual differences, and their effects on results.
4. **Editorial reminders and self-justification in the body**: Describing how the author should write, using phrases such as "we need to be precise here" or "to remain rigorous." Present verified facts and analysis directly. Apply the same check to redundant reminders and self-justification when the article discusses the writing process itself.
5. **Irrelevant or vague reservations**: Appending general possibilities unrelated to the current question, or stacking qualifiers until clear behavior becomes vague. Give calculations when possible and explain triggering conditions for behavior. Limitations must directly relate to the current conclusion.
6. **Empty language and repetition**: Repeatedly declaring importance, rigor, or lessons worth learning; prescribing how readers should feel; using headings with no concrete content; or repeating setup, previews, or summaries. Remove repetition and replace empty judgments with concrete explanations.

## Hard boundaries

- Do not infer an article type before review and use it to omit checks or relax standards.
- Do not treat examples or phrases as a keyword blacklist, or replace review with mechanical regex checks.
- Do not merely delete qualifiers and turn speculation into fact.
- Do not rewrite unrelated content or add new arguments without authorization.
- Do not flag issues to meet a quota.
- Do not substantially rewrite the original or deliberately cut and compress passages that have no prose issues.

## Counterexamples

These counterexamples come from actual article revisions. They are illustrative, not exhaustive. Do not build regex checks from them; review the article's content in context.

| Original excerpt | Problem | Revision approach |
| --- | --- | --- |
| "Neither KaTeX nor MathJax can be stated as the confirmed implementation." | Introduces unsupported technical names, then withdraws them with a negative statement. | Remove candidate names and self-justification; retain known architectural facts. |
| "Seeing source code does not mean the entire version lacks math rendering." | Invents a reader judgment and then corrects it. | State the conditions under which formulas fall back to source code. |
| "Without first crudely splitting the formula as a string." | Invents and disparages an alternative to elevate the current implementation. | Explain how the inner expression and outer structure cooperate. |
| "The version boundary for math support needs to be stated precisely." | Puts an editorial reminder to the author in the body. | State the verified version changes directly. |
| "Therefore, the remaining whitespace is not necessarily symmetrical." | In this example, the fraction is 7 columns wide and the denominator is 1 column wide, so padding can be calculated directly; the sentence instead introduces possibilities for other inputs. | State that the fraction's internal left padding is (7-1)/2=3 cells, plus two columns for the expression on the left, totaling five cells. |
| "The most valuable lesson from this design." | The heading makes a value judgment without identifying the content. | Name the heading after the actual design mechanism discussed. |

## Editing and delivery

1. When the user requests review only, list "location and original sentence -> specific issue -> suggested revision." When editing is requested or write-back is already authorized, make the edits and reread the result. Ask for the article only if it is missing.
2. Use local edits that satisfy the request, preserving the article's main thread, valid facts, necessary details, derivations, examples, citations, and authorial style. Adjust paragraphs according to content relationships.
3. Distinguish required corrections from optional concision suggestions. Ground every judgment in the original text; if there are no clear issues, say so briefly.
