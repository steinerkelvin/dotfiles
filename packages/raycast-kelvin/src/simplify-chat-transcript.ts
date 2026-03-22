import { AI, Clipboard, showHUD, showToast, Toast } from "@raycast/api";

export default async function command(props: { arguments: { style: string } }) {
  const style = props.arguments.style || "grouped";

  const clipboardText = await Clipboard.readText();
  if (!clipboardText) {
    await showHUD("❌ No text in clipboard");
    return;
  }

  const styleInstructions =
    style === "grouped"
      ? `GROUPED FORMAT:
- Group consecutive messages by sender
- Use format: [sender_name] on its own line
- List messages below it (one per line)
- Keep empty lines between sender groups

Example:
[alice]
first message
second message

[bob]
their message
another message`
      : `FLAT FORMAT:
- Keep "sender: message" format
- One message per line
- No timestamps or metadata

Example:
alice: first message
alice: second message
bob: their message
bob: another message`;

  const prompt = `Simplify and clean up this chat transcript.

Rules:
1. Remove timestamps and metadata
2. Remove any prefixes or formatting symbols
3. Keep only the sender name and message content
4. Preserve the order and message sequence
5. Handle various chat formats (Telegram, WhatsApp, Slack, etc.)

${styleInstructions}

Now clean up and simplify this chat transcript:

${clipboardText}`;

  await showHUD("⏳ Processing...");

  try {
    const result = await AI.ask(prompt);
    await Clipboard.copy(result);
    // TODO: show result text in a Raycast window with actions to paste or copy to clipboard
    await showHUD("✅ Copied to clipboard");
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Processing failed",
      message: String(error),
    });
  }
}
