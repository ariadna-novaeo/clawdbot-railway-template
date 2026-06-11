#!/bin/bash
# patch-openclaw-poll.sh — Fix OpenClaw poll param false-positive detection
#
# OpenClaw <=2026.6.5 has pollAnonymous and pollPublic in the message tool
# schema but NOT in SHARED_POLL_CREATION_PARAM_KEY_SET. When GPT-5.5 sends
# pollAnonymous:true as a default on message sends, the validation rejects
# the entire message with "Poll fields require action 'poll'".
#
# This patch adds pollAnonymous and pollPublic to the known param defs so
# they are not treated as unknown channel-specific poll params.

set -e

RUNNER=$(find /usr/local/lib/node_modules/openclaw/dist -name 'message-action-runner-*.js' 2>/dev/null | head -1)

if [ -z "$RUNNER" ]; then
  echo "[patch-poll] No message-action-runner found — skipping"
  exit 0
fi

if grep -q 'pollAnonymous' "$RUNNER"; then
  echo "[patch-poll] Already patched — skipping"
  exit 0
fi

if ! grep -q 'pollMulti: { kind: "boolean" }' "$RUNNER"; then
  echo "[patch-poll] pollMulti line not found — OpenClaw version may have changed, skipping"
  exit 0
fi

sed -i 's/pollMulti: { kind: "boolean" }/pollMulti: { kind: "boolean" },\n\tpollAnonymous: { kind: "boolean" },\n\tpollPublic: { kind: "boolean" }/' "$RUNNER"

echo "[patch-poll] Patched $RUNNER — added pollAnonymous + pollPublic to known params"
