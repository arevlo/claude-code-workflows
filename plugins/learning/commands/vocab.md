---
description: Look up a word — definition, pronunciation, and simple example (English/Spanish)
argument-hint: "[es] <word>"
allowed-tools: WebSearch,WebFetch
model: haiku
---

# Vocabulary Lookup

Look up a word and display its definition, pronunciation, and a simple example. Supports English (default) and Spanish.

## Process

1. Extract the arguments. If no arguments were provided, ask the user what word they want to look up.

2. **Detect language:** Check if the first token is `es` (case-insensitive). If so, the language is **Spanish** and the word is everything after `es`. Otherwise, the language is **English** and the entire argument is the word.

3. **Search for the word:**

   **English:** Use WebSearch to search for: `"<word>" definition pronunciation dictionary`
   Then use WebFetch on the most relevant dictionary result (prefer Merriam-Webster, Dictionary.com, or Oxford) to get the full entry.

   **Spanish:** Use WebSearch to search for: `"<word>" definicion pronunciacion diccionario site:dle.rae.es OR site:spanishdict.com OR site:wordreference.com`
   Then use WebFetch on the most relevant result (prefer RAE, SpanishDict, or WordReference) to get the full entry.

4. **Format the output:**

   **English format:**

   ```
   ## <word>

   **Pronunciation:** /<phonetic spelling>/

   **Part of speech:** <noun, verb, adjective, etc.>

   **Definition:** <clear, concise definition — prefer the most common meaning>

   **Example:** <a simple sentence a middle-schooler would understand>
   ```

   **Spanish format:**

   ```
   ## <word>

   **Pronunciacion:** /<transcripcion fonetica>/

   **Categoria gramatical:** <sustantivo, verbo, adjetivo, etc.>

   **Definicion:** <definicion clara y concisa — preferir el significado mas comun>

   **Ejemplo:** <una oracion sencilla que un estudiante de secundaria entenderia>
   ```

## Rules

- Keep it short — one primary definition, one example
- If the word has multiple parts of speech, show the most common one
- The example sentence should be straightforward and relatable for a ~12 year old
- If the word is not found, say so clearly
- **English lookups:** all output in English
- **Spanish lookups:** all output entirely in Spanish (labels, definition, example — everything)
- Do NOT save anything to a file — just display the result in the terminal
