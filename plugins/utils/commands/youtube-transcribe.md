---
description: Use when the user provides a YouTube URL to transcribe, says "transcribe this video", "grab the transcript", "youtube transcript", or wants to save a video's transcript as markdown.
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Transcribe YouTube Video

Extract captions from a YouTube video, generate a summary with key points, and save as a structured markdown note.

## Step 1: Validate input and check dependency

1. Check that `youtube_transcript_api` CLI is available:
   ```bash
   which youtube_transcript_api
   ```
   If missing, tell the user:
   > `youtube-transcript-api` is not installed. Run `pip install youtube-transcript-api` to install it. Want me to install it now?

2. Extract the video ID from the provided URL. Handle these formats:
   - `https://www.youtube.com/watch?v=VIDEO_ID`
   - `https://youtu.be/VIDEO_ID`
   - `https://youtube.com/watch?v=VIDEO_ID&t=123`
   - `https://www.youtube.com/live/VIDEO_ID`

   Use Python to extract:
   ```bash
   python3 -c "import re; m = re.search(r'(?:youtu\.be/|v=|/live/)([a-zA-Z0-9_-]{11})', 'URL'); print(m.group(1) if m else '')"
   ```

   If extraction fails, ask the user to provide a valid YouTube URL.

## Step 2: Fetch transcript

1. Fetch the transcript as JSON (prefer English, fall back to any available language):
   ```bash
   youtube_transcript_api VIDEO_ID --languages en --format json 2>&1
   ```

   If English fails, try without language filter:
   ```bash
   youtube_transcript_api VIDEO_ID --format json 2>&1
   ```

   If no captions at all, inform the user:
   > This video has no captions available. The transcript can't be extracted.

2. Save the raw JSON output for processing.

## Step 3: Extract video title

Get the video title via curl:
```bash
curl -s "https://www.youtube.com/watch?v=VIDEO_ID" | grep -o '<title>[^<]*' | sed 's/<title>//' | sed 's/ - YouTube$//'
```

If that fails, ask the user for the title.

## Step 4: Choose output location

Ask the user where to save the transcript. Suggest:
- Current project directory (e.g., `./transcripts/`)
- A custom path
- `/tmp/transcripts/` for quick access

Ensure the output directory exists:
```bash
mkdir -p <output_path>
```

## Step 5: Generate summary

Read the full transcript text (concatenate all `text` fields from the JSON). Then generate:
- **TL;DR:** A single sentence summarizing the video
- **Key Points:** 3-7 bullet points covering the main ideas (high-level themes)
- **Actionable Takeaways:** Grouped by topic, concrete things the viewer can do based on the video content. These should be specific and practical, not just restating the key points at a higher resolution. Include patterns, techniques, rules of thumb, and examples mentioned in the video.

Use your own reasoning to produce the summary. Do not call any external tool.

## Step 6: Assemble and write the markdown file

**Filename:** `MM-DD-YYYY-<slugified-title>.md`
- Slugify: lowercase, replace spaces and special chars with hyphens, collapse multiple hyphens, trim hyphens from ends
- Date: today's date in MM-DD-YYYY format

**Format the transcript** from the JSON array into natural flowing prose:
- Concatenate all segment `text` fields into continuous text
- Replace `\n` in text fields with spaces
- Remove ALL noise markers: `[music]`, `[applause]`, `[laughter]`, and similar bracketed sound/action annotations
- Merge into natural paragraphs: start a new paragraph when there is a gap of 2+ seconds between segments, and split any paragraph over ~800 characters at sentence boundaries
- The result should read like a natural transcript with proper sentences and paragraph breaks — NOT timestamped line-by-line segments
- Do NOT include timestamps in the transcript body

**Write the file with this structure:**

```markdown
---
tags: [transcript, youtube]
date: YYYY-MM-DD
source: <original youtube url>
channel: <channel name if extracted>
title: <video title>
language: <language code>
---

# <Video Title>

## Summary

**TL;DR:** <one-sentence summary>

### Key Points
- <point 1>
- <point 2>
- <point 3>

### Actionable Takeaways

**<Topic Group>**
- Specific, concrete thing the viewer can do
- Another actionable pattern or technique with example

**<Another Topic Group>**
- ...

## Transcript

First paragraph of naturally flowing text here. Multiple sentences joined together as they were spoken.

Next paragraph begins after a natural topic shift or pause...
```

Write the file using the Write tool.

If a file already exists at that path, ask the user whether to overwrite or skip.

## Step 7: Confirm

Print:
- The file path where the transcript was saved
- The TL;DR and key points summary

## Prerequisites

- [youtube-transcript-api](https://pypi.org/project/youtube-transcript-api/) (`pip install youtube-transcript-api`)
- `curl` (for fetching video title)
- Python 3
