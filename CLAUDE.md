## Agent and Region Mapping

- harshita → India & MEA region
- zara → SEA + Australia/NZ region. Includes: Singapore, Malaysia, Indonesia, Thailand, Philippines, Vietnam, Australia, New Zealand, and any Asia Pacific country that is not India.
- maya → US region

When processing Zara transcripts, any contact with Region values of Australia, New Zealand, APAC, or similar should be counted under Zara's totals.

# GoComet Call Analytics Dashboard

## Your job
Read all transcript files in the /transcripts folder, extract metrics for every agent for every date, and generate a single `dashboard.html` file with all data embedded. Do not ask questions. Read, analyze, generate, done.

---

## Folder structure
```
/transcripts/harshita/     → Harshita agent (India)
/transcripts/zara/         → Zara agent (SEA + Australia/NZ)
/transcripts/maya/         → Maya agent (US)
```
Each file is named by date: `YYYY-MM-DD.txt`
Process ALL files in ALL folders every time you run.

---

## Transcript format
Each conversation block looks like this:
```
============================================================
Conversation ID: conv_xxx
Date: YYYY-MM-DD HH:MM:SS UTC
Duration: X seconds
Agent: [name]
------------------------------------------------------------
CLIENT DATA
------------------------------------------------------------
user_name: [name]
company: [company]
region: [region]
Email: [email]
Role: [role]
------------------------------------------------------------
TRANSCRIPT
------------------------------------------------------------
Harshita/Zara/Maya: [agent speech]
Prospect: [prospect speech]
============================================================
```

---

## Step 1 — For each conversation, extract the following

### Call volume — classify as ONE of:
- **answered** — real conversation happened. Duration > 15 seconds AND prospect said more than single word responses
- **no_answer** — not picked up, very short duration, no real conversation
- **voicemail** — connected to an automated voicemail system
- **busy** — line was busy
- **unknown** — cannot determine

### For ANSWERED calls only — classify outcome as ONE of:
- **meeting_booked** — prospect agreed to a specific date and time
- **callback_requested** — prospect asked to be called back later
- **asked_for_email** — prospect only wanted an email sent
- **not_interested** — explicitly declined or said not interested
- **not_relevant** — wrong person, not in logistics, or not applicable
- **already_have_system** — uses an existing solution or competitor
- **wrong_contact** — person who answered is not the right contact
- **existing_customer** — already a GoComet customer
- **other** — answered but does not fit any of the above

Read the full transcript carefully to determine outcome:
- Meeting booked: specific date AND time confirmed by both parties
- Callback: "call back", "call later", "better time", "call tomorrow", "not a good time"
- Email: "send email", "drop a mail", "send details", "send brochure"
- Not interested: "not interested", "don't need", "remove me", "not relevant"
- Already have system: competitor name mentioned, "we use X", "we have a solution"

### For ANSWERED calls, also extract:
- **Prospect name** — from CLIENT DATA: user_name
- **Company** — from CLIENT DATA: company
- **Region** — from CLIENT DATA: Region
- **Duration** — convert seconds to mm:ss format
- **Pain points** — exact pain points the prospect mentioned. If none confirmed write "None confirmed"
- **Key note** — one sentence max. What happened on this call. Examples:
  - "Meeting booked for 3 Jun at 2pm IST"
  - "Asked to call back Thursday afternoon, mentioned invoice issues"
  - "Uses SAP TM, not looking to change currently"
  - "Not the right person, referred to logistics head"

---

## Step 2 — Aggregate metrics per agent per date

For each agent (Harshita, Zara, Maya) and each date calculate:

**Call Volume:**
- total, answered, no_answer, voicemail, busy, unknown
- percentage of total for each

**Answered Call Outcomes (counts only):**
- meeting_booked, callback_requested, asked_for_email, not_interested, not_relevant, already_have_system, wrong_contact, existing_customer, other

**Key rates:**
- answer_rate = answered / total × 100
- meeting_rate = meeting_booked / answered × 100
- positive_rate = (meeting_booked + callback_requested + asked_for_email) / answered × 100

---

## Step 3 — Generate dashboard.html

Create a single complete self-contained HTML file. All data must be hardcoded into the file as a JavaScript object — no external data fetching.

### Data structure to embed
```javascript
const ALL_DATA = {
  "2026-05-30": {
    harshita: {
      total: 98, answered: 36, no_answer: 42, voicemail: 12, busy: 5, unknown: 3,
      outcomes: { meeting_booked: 6, callback_requested: 8, asked_for_email: 5, not_interested: 9, already_have_system: 4, not_relevant: 3, other: 1 },
      calls: [
        { name: "Prospect Name", company: "Company", region: "India", duration: "3:42", outcome: "meeting_booked", pain_points: "Manual tracking", note: "Meeting booked for 3 Jun at 2pm IST" }
      ]
    },
    zara: { ... },
    maya: { ... }
  },
  "2026-05-29": { ... }
};
```

Include ALL dates from ALL transcript files. Never remove a date that already exists in the file.

### Page design

**Colours:**
- Page background: `#0f1117`
- Card background: `#1a1d27`
- Card border: `#2a2d3a`
- Table header background: `#151722`
- Primary: `#042C53`
- Green (positive): `#1D9E75`
- Amber (neutral): `#EF9F27`
- Red (negative): `#E24B4A`
- Text primary: `#ffffff`
- Text secondary: `#888888`
- Font: `system-ui, sans-serif`

**Charts:** Use Chart.js from `https://cdn.jsdelivr.net/npm/chart.js`

### Layout

**Header:**
- Left: "GoComet Call Analytics" title with "Harshita · Zara · Maya" subtitle
- Right: Date dropdown labelled "Viewing date:" + "Last updated: [timestamp]"
- Bottom border separator

**Date dropdown:**
- Lists all available dates from ALL_DATA keys, newest first
- Format: "30 May 2026"
- On change, re-render entire page content for selected date without page reload

**Overall summary row — 4 cards:**
- Total Calls (all agents combined)
- Answered (+ answer rate %)
- Meetings Booked (green, most prominent)
- Positive Outcomes (amber) — meeting + callback + email combined

**Three agent sections (Harshita / Zara / Maya), each containing:**

1. Agent header with region badge:
   - Harshita: navy badge labelled "India"
   - Zara: teal badge labelled "SEA"
   - Maya: purple badge labelled "US"

2. Call volume row — 6 cards: Total | Answered (green) | No Answer | Voicemail | Busy | Unknown
   - Each card shows count and % of total

3. Two charts side by side:
   - Left: Donut chart — call volume breakdown (Answered / No Answer / Voicemail / Busy / Unknown)
   - Right: Donut chart — answered outcomes breakdown

4. Outcome summary table:
   - Columns: Outcome | Count | % of Answered | Distribution bar
   - Colour coded: meeting_booked = green, callback/email = amber, not_interested = red, rest = grey
   - Sorted by count descending

5. Answered call details table:
   - Columns: Prospect | Company | Region | Duration | Outcome | Pain Points | Key Note
   - One row per answered call
   - Outcome column is a coloured badge (green/amber/red/grey)
   - Table is scrollable vertically (max-height: 300px) and horizontally
   - Sorted: meeting_booked first, then callback, then email, then rest
   - If no answered calls: show "No answered calls for this date"

**Footer:** "Generated by Claude Code · GoComet Internal · Not for external distribution"

### Outcome colour coding
- meeting_booked → green `#1D9E75`
- callback_requested → amber `#EF9F27`
- asked_for_email → yellow `#f0c060`
- not_interested → red `#E24B4A`
- already_have_system → grey `#888`
- not_relevant → grey `#666`
- wrong_contact → grey `#555`
- existing_customer → grey `#555`
- other → grey `#444`

---

## Step 4 — If dashboard.html already exists

Open the existing file, read the ALL_DATA object, keep all existing dates, and ADD any new dates found in the transcripts. Never overwrite or remove existing date entries. Only add new ones.

---

## Step 5 — Print a summary when done

After generating the file, print:
```
✓ Dates processed: [list all dates]
✓ Harshita: [total calls] calls, [answered] answered, [meetings] meetings booked
✓ Zara: [total calls] calls, [answered] answered, [meetings] meetings booked
✓ Maya: [total calls] calls, [answered] answered, [meetings] meetings booked
✓ dashboard.html updated successfully
```
