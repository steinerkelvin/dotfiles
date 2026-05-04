import { Clipboard, showHUD } from "@raycast/api";

export default async function command() {
  const text = await Clipboard.readText();
  if (!text) {
    await showHUD("❌ No text in clipboard");
    return;
  }

  const cleaned = text.replace(/[^\S\r\n]+(?=\r?\n|$)/g, "");

  if (cleaned === text) {
    await showHUD("✅ Clipboard already clean");
    return;
  }

  await Clipboard.copy(cleaned);
  await showHUD("✅ Cleaned and copied");
}
