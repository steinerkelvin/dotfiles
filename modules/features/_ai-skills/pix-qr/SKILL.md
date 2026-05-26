---
name: pix-qr
description: Generate a Brazilian PIX BR Code (EMV) — produces both the Copia e Cola string and a scannable QR PNG. Use when the user wants to create a PIX payment QR, "gere um QR pra esse PIX", "make a PIX QR code", or shares chave + valor and asks for a QR. Supports CPF, CNPJ, email, phone (E.164 or BR-format), and aleatória UUID keys. Amount is optional — omit for payer-fills mode.
allowed-tools:
  - Read
  - Bash
---

# pix-qr

Generate a static PIX BR Code (EMV-MPM with Brazilian extensions) for a beneficiary. Outputs both the Copia e Cola string and a QR PNG.

## When to use

- User asks "gera/gere um QR pra esse PIX" / "make a PIX QR code" / "QR code do pix"
- User shares a chave PIX + nome + cidade and asks for a payment QR
- User wants to test or preview a BR Code without going through their bank app

This is a **static QR** (single beneficiary, fixed or open amount). Not for one-time dynamic QRs (those require a backend that hosts the payload).

## Inputs you need

Gather these before calling the script. Ask only for what's missing:

| Field      | Required | Notes                                                              |
| ---------- | -------- | ------------------------------------------------------------------ |
| `chave`    | yes      | CPF, CNPJ, email, phone (+5511..., or BR-formatted), or aleatória  |
| `nome`     | yes      | Beneficiary name. ≤25 chars after ASCII-fold + uppercase           |
| `cidade`   | yes      | Beneficiary city. ≤15 chars after ASCII-fold + uppercase           |
| `valor`    | no       | BRL amount (e.g. `116.48` or `116,48`). Omit → payer fills at scan |
| `txid`     | no       | Transaction ID ≤25 chars. Default `***` = generic                  |
| `out`      | no       | Output PNG path. Default: `./pix-<short>.png` in cwd               |

When the user only gives you a chave + valor (e.g. from an email forwarding "PIX: 33929379000178"), reasonable defaults if you can infer them from context (sender's name, prior emails, the city in their signature) — but **confirm the beneficiary name and city** before running. Wrong name/city in the QR doesn't usually break the transfer (the payer's bank shows the real beneficiary), but it can create confusion at scan time.

## How to invoke

```sh
uv run ~/.claude/skills/pix-qr/pix_qr.py \
  --chave 'CHAVE_HERE' \
  --nome 'NOME BENEFICIARIO' \
  --cidade 'CIDADE' \
  [--valor 116.48] \
  [--txid PEDIDO123] \
  [--out /tmp/pix.png] \
  [--no-qr]
```

The script prints the Copia e Cola, key type detection, and the absolute path of the PNG. Read the PNG back with the Read tool to display it inline to the user.

## Output presentation

After generation, present:

1. **Copia e Cola string** in a code block — many bank apps accept paste-only and don't need the QR.
2. **QR PNG** displayed inline (Read the file path).
3. **Beneficiary metadata** (chave, nome, cidade, valor) — so the user can sanity-check before paying.
4. **Caveat about the chave type** if you inferred it from raw input — the script will print the detected type, repeat it back to the user.

## Common pitfalls

- **Phone format.** Bare `27999998888` → script coerces to `+5527999998888`. If the chave was registered with a different format, the QR won't resolve. When in doubt, ask the user to confirm the exact registered format.
- **Diacritics in name/city.** PIX BR Code requires ASCII; the script strips diacritics and uppercases. "São Paulo" → "SAO PAULO". Mention this so the user isn't surprised.
- **Valor with comma vs dot.** Both accepted; comma is normalized to dot for the EMV field.
- **TXID length.** Spec allows up to 25 chars. Longer values are truncated silently — flag if user provides a longer string.
- **Static vs dynamic.** This skill produces static QRs only. If the user mentions "QR único", "one-time QR", or wants merchant-style dynamic QRs (with online amount verification), say it's out of scope and recommend their bank app's "PIX cobrar" feature.

## Verify before sending

If the QR is for a real payment, encourage the user to verify:

- The beneficiary name shown by the payer's bank app matches expectations.
- The amount matches what was agreed.
- The CRC at the end of the Copia e Cola is uppercase 4-hex-char.

If something looks off, re-run with corrected fields rather than hand-editing the EMV string (the CRC will desync).
