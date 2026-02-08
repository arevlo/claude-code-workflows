---
description: Look up a grammar or punctuation rule — usage, examples, and common mistakes (English/Spanish)
argument-hint: "[es] <rule or punctuation mark>"
allowed-tools: WebSearch,WebFetch
model: haiku
---

# Grammar & Punctuation Lookup

Look up a grammar or punctuation rule and display practical guidance with real-world examples. Supports English (default) and Spanish.

## Process

1. Extract the arguments. If no arguments were provided, ask the user what grammar rule or punctuation mark they want to look up. Suggest a few examples:
   - English: semicolons, em dashes, oxford comma, who vs whom, affect vs effect
   - Spanish: punto y coma, tilde, signos de interrogacion, por que vs porque, ser vs estar

2. **Detect language:** Check if the first token is `es` (case-insensitive). If so, the language is **Spanish** and the topic is everything after `es`. Otherwise, the language is **English** and the entire argument is the topic.

3. **Search for the rule:**

   **English:** Use WebSearch to search for: `<topic> grammar rule usage examples site:grammarly.com OR site:owl.purdue.edu OR site:chicagomanualofstyle.org`
   Then use WebFetch on the most relevant result to get the full explanation.

   **Spanish:** Use WebSearch to search for: `<topic> regla gramatical uso ejemplos site:dle.rae.es OR site:fundeu.es OR site:wikilengua.org`
   Then use WebFetch on the most relevant result to get the full explanation.

4. **Format the output:**

   **English format:**

   ```
   ## <topic>

   **What it is:** <one-sentence description of the rule or mark>

   **When to use it:**
   - <most common use case>
   - <second common use case>
   - <third common use case, if relevant>

   **Examples:**
   - <correct usage> — <brief explanation>
   - <correct usage> — <brief explanation>

   **Common mistakes:**
   - <wrong usage> -> <corrected version>
   - <wrong usage> -> <corrected version>

   **Quick tip:** <one memorable takeaway>
   ```

   **Spanish format:**

   ```
   ## <tema>

   **Que es:** <descripcion en una oracion de la regla o signo>

   **Cuando se usa:**
   - <caso de uso mas comun>
   - <segundo caso de uso comun>
   - <tercer caso de uso, si aplica>

   **Ejemplos:**
   - <uso correcto> — <breve explicacion>
   - <uso correcto> — <breve explicacion>

   **Errores comunes:**
   - <uso incorrecto> -> <version corregida>
   - <uso incorrecto> -> <version corregida>

   **Consejo rapido:** <un dato memorable para recordar>
   ```

## Rules

- Be practical over exhaustive — focus on the 2-3 most useful things to know
- Use real-world examples, not textbook-sounding ones
- Always highlight common mistakes — that's where the most value is
- Keep the quick tip memorable and actionable
- **English lookups:** all output in English
- **Spanish lookups:** all output entirely in Spanish (labels, explanations, examples — everything)
- Do NOT save anything to a file — just display the result in the terminal
