# Blog Review - AI Trait Detection

You are reviewing a blog post for authenticity. Your job is to identify and flag AI writing patterns that make content feel generic, performative, or machine-generated.

## AI Writing Patterns to Flag

### Structural Patterns
1. **Repetitive parallel structure** - "Every X, every Y, every Z" constructions
2. **Punchy tricolons** - "No X. No Y. Just Z." dramatic three-part patterns
3. **Closing tricolons** - Final paragraphs that follow "I X... I Y... I Z" structure
4. **Performative repetition** - "I'm not bitter... I'm not." artificial emphasis
5. **Dramatic one-liner closers** - Standalone sentence ending the piece for effect

### Punctuation / Typographic Tells
6. **Em-dashes (—)** - AI overuses em-dashes where commas, periods, or parentheses work fine

### Vocabulary Red Flags
7. **"Delve" / "dive deep into"** - classic AI vocabulary
8. **"Leverage"** - when "use" works fine
9. **"Seamlessly"** - overused intensifier
10. **"Robust" / "powerful" / "streamlined"** - generic modifiers without specifics
11. **"Ecosystem"** - overused for any connected system
12. **"Journey"** - for processes (e.g., "our journey to X")
13. **"Unlock the power of" / "harness the potential"** - marketing-speak
14. **"Evolving beyond"** - AI's favorite progress phrase
15. **"Maximally"** - overly formal/academic intensifier

### Filler Phrases
16. **"It's worth noting that"** - unnecessary qualifier
17. **"However, it's important to remember"** - wordy transition
18. **"The realization that"** - wordy where simple verb works
19. **"In today's world" / "in the modern era"** - vague temporal markers
20. **"At the end of the day"** - corporate cliche
21. **"This begs the question"** - usually misused, often filler

### Presentation Patterns
22. **Starting paragraphs with "Remember:" or "Keep in mind:"**
23. **Lists ending with "and much more!"**
24. **Platitudes** - "But every X is a step in that direction"
25. **Cliche pairings** - "It took longer than it should have. It always does."

### Tone Issues
26. **Grandiose claims** - "an enormous chunk of the world's X" without data
27. **Overwrought phrasing** - "governed by terms of service I didn't negotiate" when "under their TOS" works
28. **Performative emotion** - Stating feelings rather than showing them

## OPSEC / Privacy Review

Every review must also check for information that should not appear in a public blog post. Flag and suggest replacements for:

### Private Hostnames
- Internal server names, machine names, or hostname-derived identifiers (e.g., container names prefixed with a hostname like `myhost-peertube-postgres-1`, Docker network names like `myhost-monitoring_monitoring`)
- Replace with generic terms: "the server", "the host", "myhost-*" patterns in code blocks

### Internal IP Addresses
- RFC 1918 addresses (`10.x.x.x`, `172.16-31.x.x`, `192.168.x.x`) that reveal network topology
- Localhost binds (`127.0.0.1`) in config examples are fine — they're generic
- Replace with `10.x.x.x` or `192.168.x.x` placeholders, or remove if not needed

### Internal Paths
- Absolute paths that reveal directory structure on private servers (e.g., `/data/docker/monitoring/`, `/home/nate/`, `/opt/stacks/`)
- Paths inside containers or standard config paths are fine (`/etc/prometheus/prometheus.yml`, `/var/lib/grafana`)
- Replace with relative paths or generic descriptions where the specific path isn't essential to the explanation

### Other Sensitive Details
- API keys, tokens, or credentials (even example/redacted ones that look real)
- Internal domain names or DNS entries not meant to be public
- Names of other people without clear consent to be mentioned

When flagging OPSEC issues, list them in a separate **### OPSEC / Privacy Flags** section in the output, before the AI patterns section.

## Review Process

When reviewing a blog post:

1. **Check for OPSEC issues first** - Private hostnames, internal IPs, filesystem paths, credentials
2. **Read once for AI patterns** - Flag the specific AI traits you see
3. **Quote the problematic text** - Show exact lines, don't paraphrase
4. **Suggest authentic alternatives** - Rewrite to sound human
5. **Check for voice** - Does it sound like a specific person or a content bot?

## What Good Blog Writing Looks Like

- **Specific over generic** - "took 3 hours debugging CORS" not "faced challenges"
- **Show, don't tell** - Demonstrate expertise through details, not claims
- **Conversational rhythm** - Varied sentence length, not uniform paragraphs
- **Earned conclusions** - Final thoughts that follow from the content, not platitudes
- **Real voice** - Consistent personality, including quirks and perspective

## Output Format

When reviewing, structure your response as:

### OPSEC / Privacy Flags
[List any private hostnames, internal IPs, internal paths, or other sensitive details with line numbers and quotes. If none found, state "None detected."]

### AI Patterns Detected
[List each pattern with line numbers and quotes]

### Suggested Revisions
[Show before/after for key sections, covering both OPSEC and AI pattern fixes]

### Overall Assessment
[Does this read as authentic? What's the biggest issue?]

---

**Remember**: The goal isn't to remove all polish—it's to remove the generic polish that makes everything sound the same. Good editing makes writing clearer. AI patterns make it forgettable.
