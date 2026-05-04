/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `clean-terminal-paste` command */
  export type CleanTerminalPaste = ExtensionPreferences & {}
  /** Preferences accessible in the `simplify-chat-transcript` command */
  export type SimplifyChatTranscript = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `clean-terminal-paste` command */
  export type CleanTerminalPaste = {}
  /** Arguments passed to the `simplify-chat-transcript` command */
  export type SimplifyChatTranscript = {
  /** Format Style */
  "style": "grouped" | "flat"
}
}

