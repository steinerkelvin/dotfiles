import { Clipboard, showHUD } from "@raycast/api";

export default async function command() {
  const text = await Clipboard.readText();
  if (!text) {
    await showHUD("❌ No text in clipboard");
    return;
  }

  const cleaned = text
    .replace(/\r\n?/g, "\n")
    .split("\n")
    .map((line) => line.replace(/[ \t]+$/, ""))
    .join("\n")
    .replace(/\n+$/, "\n");

  if (cleaned === text) {
    await showHUD("✅ Clipboard already clean");
    return;
  }

  await Clipboard.copy(cleaned);
  await showHUD("✅ Cleaned and copied");
}
