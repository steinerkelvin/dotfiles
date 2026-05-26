#!/usr/bin/env -S uv run --quiet
# /// script
# dependencies = ["qrcode[pil]"]
# ///
"""Generate a Brazilian PIX BR Code (EMV) — Copia e Cola string + QR PNG.

Static QR (single fixed beneficiary). Amount is optional: when omitted, the
payer's bank app will prompt for the amount at scan time.

Usage:
    uv run pix_qr.py --chave 33929379000178 --nome 'ME WE IMOVEIS' --cidade VITORIA --valor 116.48
    uv run pix_qr.py --chave +5527999998888 --nome 'JOAO SILVA' --cidade VITORIA
    uv run pix_qr.py --chave foo@bar.com --nome 'JOAO SILVA' --cidade VITORIA --txid PEDIDO123 --out /tmp/foo.png

Spec: BCB BR Code (EMV-MPM with PIX extensions).
"""

from __future__ import annotations

import argparse
import re
import sys
import unicodedata
from pathlib import Path

import qrcode


def tlv(tag: str, value: str) -> str:
    if len(tag) != 2 or not tag.isdigit():
        raise ValueError(f"invalid tag: {tag!r}")
    return f"{tag}{len(value):02d}{value}"


def crc16_ccitt(data: bytes) -> int:
    """CRC-16/CCITT-FALSE (poly 0x1021, init 0xFFFF) — required by BR Code spec."""
    crc = 0xFFFF
    for b in data:
        crc ^= b << 8
        for _ in range(8):
            crc = ((crc << 1) ^ 0x1021) if (crc & 0x8000) else (crc << 1)
            crc &= 0xFFFF
    return crc


def detect_chave_type(raw: str) -> tuple[str, str]:
    """Return (kind, normalized_chave). kind is informational only — the BR
    Code itself doesn't carry the chave type, but normalization differs."""
    s = raw.strip()
    if "@" in s:
        return ("email", s.lower())
    digits = re.sub(r"\D", "", s)
    if s.startswith("+") and 11 <= len(digits) <= 14:
        return ("phone", "+" + digits)
    if len(digits) == 11 and not re.match(r"^\d{2}9?\d{8}$", s) and s == digits:
        return ("cpf", digits)
    if len(digits) == 14:
        return ("cnpj", digits)
    if 10 <= len(digits) <= 13 and digits == re.sub(r"\D", "", s):
        # bare phone digits (BR mobile) — coerce to E.164 with +55 if 10-11 digits
        if len(digits) in (10, 11):
            return ("phone", "+55" + digits)
        return ("phone", "+" + digits)
    if re.fullmatch(r"[0-9a-fA-F]{8}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{12}", s):
        return ("aleatoria", s.lower())
    return ("unknown", s)


def fold_ascii(s: str, max_len: int) -> str:
    """BR Code limits name/city to ASCII (BCB convention). Strip diacritics,
    uppercase, truncate."""
    folded = unicodedata.normalize("NFKD", s)
    folded = "".join(c for c in folded if not unicodedata.combining(c))
    folded = folded.encode("ascii", "replace").decode("ascii").upper()
    return folded[:max_len].strip()


def build_payload(
    *,
    chave: str,
    nome: str,
    cidade: str,
    valor: str | None,
    txid: str = "***",
) -> str:
    nome_clean = fold_ascii(nome, 25)
    cidade_clean = fold_ascii(cidade, 15)

    mai = tlv("00", "BR.GOV.BCB.PIX") + tlv("01", chave)

    parts = [
        tlv("00", "01"),                    # Payload Format Indicator
        tlv("01", "11"),                    # PoIM = static
        tlv("26", mai),                     # Merchant Account Information
        tlv("52", "0000"),                  # MCC unspecified
        tlv("53", "986"),                   # Currency BRL
    ]
    if valor:
        # Spec: up to 13 chars, "." decimal separator, 2 fraction digits
        try:
            v = float(valor.replace(",", "."))
        except ValueError as e:
            raise SystemExit(f"invalid --valor: {valor}") from e
        parts.append(tlv("54", f"{v:.2f}"))
    parts.extend([
        tlv("58", "BR"),
        tlv("59", nome_clean),
        tlv("60", cidade_clean),
        tlv("62", tlv("05", txid[:25])),    # TXID, max 25 chars
        "6304",                              # CRC tag + length, value below
    ])

    payload_no_crc = "".join(parts)
    crc = crc16_ccitt(payload_no_crc.encode("utf-8"))
    return payload_no_crc + f"{crc:04X}"


def main() -> int:
    p = argparse.ArgumentParser(description="Generate a static PIX BR Code (Copia e Cola + QR PNG).")
    p.add_argument("--chave", required=True, help="PIX key: CPF, CNPJ, email, phone (+E.164), or aleatória UUID.")
    p.add_argument("--nome", required=True, help="Beneficiary name (≤25 chars; diacritics stripped, uppercased).")
    p.add_argument("--cidade", required=True, help="Beneficiary city (≤15 chars; diacritics stripped, uppercased).")
    p.add_argument("--valor", help="Amount in BRL (e.g. 116.48). Omit for payer-fills mode.")
    p.add_argument("--txid", default="***", help="Optional transaction ID (≤25 chars). Default '***' = generic.")
    p.add_argument("--out", help="Output PNG path. Default: ./pix-<short>.png")
    p.add_argument("--no-qr", action="store_true", help="Skip PNG generation; print Copia e Cola only.")
    args = p.parse_args()

    kind, chave = detect_chave_type(args.chave)
    payload = build_payload(
        chave=chave,
        nome=args.nome,
        cidade=args.cidade,
        valor=args.valor,
        txid=args.txid,
    )

    print("--- PIX Copia e Cola ---")
    print(payload)
    print()
    print(f"Chave type:  {kind}")
    print(f"Chave value: {chave}")
    if args.valor:
        print(f"Valor:       R$ {args.valor}")
    else:
        print("Valor:       (payer fills at scan)")
    print(f"Length:      {len(payload)} chars")

    if not args.no_qr:
        out_path = Path(args.out) if args.out else Path(f"pix-{chave[:8]}.png")
        img = qrcode.make(payload)
        img.save(out_path)
        print(f"QR saved:    {out_path.resolve()}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
