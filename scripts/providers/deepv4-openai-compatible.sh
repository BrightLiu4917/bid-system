#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-}"

if [[ -z "$INPUT_FILE" || ! -f "$INPUT_FILE" ]]; then
  printf 'Usage: %s .agent/reviews/deepv4-input.md\n' "$0" >&2
  exit 2
fi

: "${DEEPV4_BASE_URL:?DEEPV4_BASE_URL is required, for example https://api.example.com/v1}"
: "${DEEPV4_API_KEY:?DEEPV4_API_KEY is required}"
: "${DEEPV4_MODEL:?DEEPV4_MODEL is required}"
DEEPV4_CONNECT_TIMEOUT="${DEEPV4_CONNECT_TIMEOUT:-20}"
DEEPV4_MAX_TIME="${DEEPV4_MAX_TIME:-180}"
DEEPV4_MAX_INPUT_BYTES="${DEEPV4_MAX_INPUT_BYTES:-80000}"

if ! command -v curl >/dev/null 2>&1; then
  printf 'curl is required.\n' >&2
  exit 127
fi

if ! command -v node >/dev/null 2>&1; then
  printf 'node is required to build JSON safely.\n' >&2
  exit 127
fi

PAYLOAD_FILE="$(mktemp)"
RESPONSE_FILE="$(mktemp)"
TRUNCATED_INPUT_FILE="$(mktemp)"
trap 'rm -f "$PAYLOAD_FILE" "$RESPONSE_FILE" "$TRUNCATED_INPUT_FILE"' EXIT

input_size="$(wc -c < "$INPUT_FILE" | tr -d ' ')"
if [[ "$input_size" -gt "$DEEPV4_MAX_INPUT_BYTES" ]]; then
  {
    printf '# Input truncated for deepv4 review\n\n'
    printf 'Original input size: %s bytes\n' "$input_size"
    printf 'Truncated input limit: %s bytes\n\n' "$DEEPV4_MAX_INPUT_BYTES"
    printf 'The original review input is too large. Review the visible subset and explicitly report that the input was truncated.\n\n'
    head -c "$DEEPV4_MAX_INPUT_BYTES" "$INPUT_FILE"
  } > "$TRUNCATED_INPUT_FILE"
  INPUT_FILE="$TRUNCATED_INPUT_FILE"
fi

node - "$INPUT_FILE" > "$PAYLOAD_FILE" <<'NODE'
const fs = require("fs");
const inputFile = process.argv[2];
const content = fs.readFileSync(inputFile, "utf8");
const payload = {
  model: process.env.DEEPV4_MODEL,
  temperature: Number(process.env.DEEPV4_TEMPERATURE || "0.1"),
  messages: [
    {
      role: "system",
      content:
        "You are an independent production code reviewer. Do not rewrite code. Report only concrete risks, missing confirmations, and missing tests. If evidence is insufficient, mark it as a question needing confirmation."
    },
    {
      role: "user",
      content
    }
  ]
};
process.stdout.write(JSON.stringify(payload));
NODE

printf 'DEEPV4_HTTP_REQUEST: %s/chat/completions\n' "${DEEPV4_BASE_URL%/}" >&2

curl -fsS \
  --connect-timeout "$DEEPV4_CONNECT_TIMEOUT" \
  --max-time "$DEEPV4_MAX_TIME" \
  -H "Authorization: Bearer ${DEEPV4_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @"$PAYLOAD_FILE" \
  -o "$RESPONSE_FILE" \
  "${DEEPV4_BASE_URL%/}/chat/completions"

node - "$RESPONSE_FILE" <<'NODE'
const fs = require("fs");
const responseFile = process.argv[2];
const text = fs.readFileSync(responseFile, "utf8");
const data = JSON.parse(text);
const choice = data.choices && data.choices[0];
const message = choice && choice.message && choice.message.content;
if (!message) {
  process.stdout.write(text);
  process.exit(0);
}
process.stdout.write(message);
NODE
