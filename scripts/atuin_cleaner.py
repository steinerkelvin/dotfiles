#!/usr/bin/env python3
"""
Atuin History Cleaner

This script helps analyze and clean your Atuin shell history.
It identifies and categorizes commands based on exit codes and patterns,
and provides recommendations for cleaning.

Usage:
    python3 atuin_cleaner.py analyze
    python3 atuin_cleaner.py interactive
    python3 atuin_cleaner.py clean [--dry-run] [--confirm]
"""

import argparse
import json
import os
import re
import subprocess
import sys
from collections import Counter, defaultdict
from datetime import datetime
from difflib import SequenceMatcher
from typing import Dict, List, Set, Tuple


class AtuinHistoryCleaner:
    def __init__(self):
        self.history = []
        self.load_history()

    def load_history(self) -> None:
        """Load history from atuin"""
        try:
            # Use JSON output format for reliable parsing
            result = subprocess.run(
                ["atuin", "history", "list", "--format", "{exit}\t{command}\t{time}"],
                capture_output=True,
                text=True,
                check=True,
            )
            
            # Parse history entries
            self.history = []
            for line in result.stdout.strip().split("\n"):
                if not line.strip():
                    continue
                
                parts = line.split("\t", 2)
                if len(parts) < 3:
                    continue
                    
                exit_code_str, command, timestamp = parts
                try:
                    exit_code = int(exit_code_str)
                except ValueError:
                    exit_code = -1
                    
                self.history.append({
                    "exit_code": exit_code,
                    "command": command,
                    "timestamp": timestamp
                })
                
            print(f"Loaded {len(self.history)} history entries")
            
        except subprocess.CalledProcessError as e:
            print(f"Error loading history: {e}")
            sys.exit(1)

    def analyze_history(self) -> Dict:
        """Analyze history and return statistics"""
        stats = {
            "total_commands": len(self.history),
            "exit_code_distribution": Counter(),
            "command_frequencies": Counter(),
            "command_success_rates": {},
            "potential_typos": [],
            "invalid_paths": [],
            "interrupted_commands": [],
            "not_found_commands": [],
        }
        
        # Command first words
        command_words = defaultdict(list)
        
        # Process history
        for entry in self.history:
            exit_code = entry["exit_code"]
            command = entry["command"]
            
            stats["exit_code_distribution"][exit_code] += 1
            
            # Extract first word of command
            first_word = command.split()[0] if " " in command else command
            stats["command_frequencies"][first_word] += 1
            
            # Track success/failure by command
            if first_word not in stats["command_success_rates"]:
                stats["command_success_rates"][first_word] = {"total": 0, "success": 0}
            
            stats["command_success_rates"][first_word]["total"] += 1
            if exit_code == 0:
                stats["command_success_rates"][first_word]["success"] += 1
                
            # Group commands by first word
            command_words[first_word].append({"exit_code": exit_code, "command": command})
            
            # Find "command not found" errors (exit code 127)
            if exit_code == 127:
                stats["not_found_commands"].append(command)
                
            # Find interrupted commands (exit code 130)
            if exit_code == 130:
                stats["interrupted_commands"].append(command)
                
            # Detect invalid path operations
            if (re.search(r"(mkdir|touch|cd|ls|cat)\s+[^\s/]+/", command) and 
                exit_code != 0 and not command.startswith("cd /")):
                stats["invalid_paths"].append(command)
        
        # Calculate success rates
        for cmd, data in stats["command_success_rates"].items():
            if data["total"] >= 5:  # Only for commands used at least 5 times
                data["rate"] = data["success"] / data["total"] * 100
        
        # Find potential typos
        unique_commands = set(entry["command"] for entry in self.history)
        for cmd1 in unique_commands:
            first_word1 = cmd1.split()[0] if " " in cmd1 else cmd1
            for cmd2 in unique_commands:
                if cmd1 == cmd2:
                    continue
                first_word2 = cmd2.split()[0] if " " in cmd2 else cmd2
                
                # Check if first words are similar but not identical
                if (first_word1 != first_word2 and 
                    len(first_word1) > 2 and len(first_word2) > 2 and
                    SequenceMatcher(None, first_word1, first_word2).ratio() > 0.7):
                    stats["potential_typos"].append((first_word1, first_word2))
        
        return stats

    def print_analysis(self, stats: Dict) -> None:
        """Print analysis results in a readable format"""
        print("\n=== ATUIN HISTORY ANALYSIS ===")
        print(f"Total commands: {stats['total_commands']}")
        
        print("\n== Exit Code Distribution ==")
        for code, count in sorted(stats["exit_code_distribution"].items()):
            percentage = (count / stats["total_commands"]) * 100
            code_meaning = self.explain_exit_code(code)
            print(f"Exit code {code}: {count} commands ({percentage:.1f}%) - {code_meaning}")
        
        print("\n== Commands with Low Success Rates (<60%) ==")
        print("Command | Total Uses | Success Rate")
        print("--------|------------|-------------")
        for cmd, data in stats["command_success_rates"].items():
            if data.get("rate", 100) < 60 and data["total"] >= 5:
                print(f"{cmd:8} | {data['total']:10} | {data['rate']:.1f}%")
        
        print("\n== Potential Typos ==")
        seen_pairs = set()
        for cmd1, cmd2 in stats["potential_typos"]:
            pair = tuple(sorted([cmd1, cmd2]))
            if pair not in seen_pairs:
                seen_pairs.add(pair)
                print(f"{cmd1} <-> {cmd2}")
                
        print("\n== Command Not Found (samples) ==")
        for cmd in stats["not_found_commands"][:20]:  # Show only first 20
            print(f"- {cmd}")
        if len(stats["not_found_commands"]) > 20:
            print(f"... and {len(stats['not_found_commands']) - 20} more")
            
        print("\n== Interrupted Commands (samples) ==")
        for cmd in stats["interrupted_commands"][:20]:  # Show only first 20
            print(f"- {cmd}")
        if len(stats["interrupted_commands"]) > 20:
            print(f"... and {len(stats['interrupted_commands']) - 20} more")
            
        print("\n== Invalid Path Operations (samples) ==")
        for cmd in stats["invalid_paths"][:20]:  # Show only first 20
            print(f"- {cmd}")
        if len(stats["invalid_paths"]) > 20:
            print(f"... and {len(stats['invalid_paths']) - 20} more")
            
        print("\n=== RECOMMENDATIONS ===")
        print("1. Delete 'command not found' entries (exit code 127)")
        print("2. Review and clean potential typos")
        print("3. Clean invalid path operations")
        print("4. Consider setting up atuin exclusion filters for common patterns")

    def explain_exit_code(self, code: int) -> str:
        """Explain what an exit code means"""
        explanations = {
            0: "Success",
            1: "General error",
            2: "Misuse of shell builtins",
            126: "Command invoked cannot execute",
            127: "Command not found",
            128: "Invalid exit argument",
            129: "SIGHUP (Hangup)",
            130: "SIGINT (Terminal interrupt, usually Ctrl+C)",
            131: "SIGQUIT (Terminal quit)",
            137: "SIGKILL (Kill signal)",
            143: "SIGTERM (Termination signal)",
        }
        
        return explanations.get(code, "Unknown")

    def get_candidates_for_deletion(self) -> Dict[str, List[str]]:
        """Get candidates for deletion based on different categories"""
        stats = self.analyze_history()
        
        candidates = {
            "not_found": stats["not_found_commands"],
            "interrupted": [],  # We don't delete all interrupted commands by default
            "invalid_paths": stats["invalid_paths"],
            "typos": [],  # Need further processing
        }
        
        # Process potential typos
        seen_pairs = set()
        for cmd1, cmd2 in stats["potential_typos"]:
            pair = tuple(sorted([cmd1, cmd2]))
            if pair not in seen_pairs:
                seen_pairs.add(pair)
                
                # Check which one has a higher failure rate
                rate1 = stats["command_success_rates"].get(cmd1, {}).get("rate", 100)
                rate2 = stats["command_success_rates"].get(cmd2, {}).get("rate", 100)
                
                # If one is significantly worse than the other, mark it as a typo
                if rate1 < 50 and rate2 > 70:
                    candidates["typos"].append(cmd1)
                elif rate2 < 50 and rate1 > 70:
                    candidates["typos"].append(cmd2)
        
        return candidates

    def run_interactive_cleaning(self) -> None:
        """Run interactive cleaning session"""
        stats = self.analyze_history()
        candidates = self.get_candidates_for_deletion()
        
        print("\n=== INTERACTIVE CLEANING SESSION ===")
        print("Review and confirm deletions for each category.")
        
        to_delete = []
        
        # 1. Command not found
        print(f"\n== Command Not Found (Exit Code 127): {len(candidates['not_found'])} commands ==")
        if self.confirm("Review 'command not found' entries?"):
            reviewed = self.review_list(candidates["not_found"], "command not found")
            to_delete.extend(reviewed)
            
        # 2. Invalid paths
        print(f"\n== Invalid Path Operations: {len(candidates['invalid_paths'])} commands ==")
        if self.confirm("Review invalid path operations?"):
            reviewed = self.review_list(candidates['invalid_paths'], "invalid path")
            to_delete.extend(reviewed)
            
        # 3. Potential typos
        print(f"\n== Potential Typos: {len(candidates['typos'])} commands ==")
        if self.confirm("Review potential typos?"):
            reviewed = self.review_list(candidates['typos'], "potential typo")
            to_delete.extend(reviewed)
        
        # 4. Custom patterns
        if self.confirm("Add custom patterns to search for?"):
            while True:
                pattern = input("Enter search pattern (or empty to stop): ").strip()
                if not pattern:
                    break
                    
                matches = [entry["command"] for entry in self.history 
                          if re.search(pattern, entry["command"])]
                
                if matches:
                    print(f"Found {len(matches)} matches for pattern '{pattern}'")
                    reviewed = self.review_list(matches, f"match for '{pattern}'")
                    to_delete.extend(reviewed)
                else:
                    print(f"No matches found for pattern '{pattern}'")
        
        # Execute deletion
        if to_delete:
            if self.confirm(f"Delete {len(to_delete)} selected commands? THIS CANNOT BE UNDONE"):
                self.delete_commands(to_delete)
        else:
            print("No commands selected for deletion.")

    def review_list(self, items: List[str], category: str) -> List[str]:
        """Review a list of items and return those to delete"""
        to_delete = []
        
        if not items:
            print(f"No {category} items to review.")
            return to_delete
            
        print(f"\nReviewing {len(items)} {category} items:")
        
        batch_size = 10
        for i in range(0, len(items), batch_size):
            batch = items[i:i+batch_size]
            
            print("\nCommands:")
            for idx, cmd in enumerate(batch, 1):
                print(f"{idx}. {cmd}")
                
            selection = input(f"Enter numbers to delete (e.g. 1,3,5-7), 'a' for all, 's' to skip batch, 'q' to finish: ").strip()
            
            if selection.lower() == 'q':
                break
            elif selection.lower() == 's':
                continue
            elif selection.lower() == 'a':
                to_delete.extend(batch)
            elif selection:
                try:
                    # Parse selections like 1,3,5-7
                    for part in selection.split(','):
                        if '-' in part:
                            start, end = map(int, part.split('-'))
                            if 1 <= start <= end <= len(batch):
                                to_delete.extend(batch[idx-1] for idx in range(start, end+1))
                        else:
                            idx = int(part)
                            if 1 <= idx <= len(batch):
                                to_delete.append(batch[idx-1])
                except ValueError:
                    print("Invalid selection, skipping batch.")
        
        return to_delete

    def confirm(self, question: str) -> bool:
        """Ask for confirmation"""
        response = input(f"{question} (y/n): ").lower()
        return response.startswith('y')

    def delete_commands(self, commands: List[str], dry_run: bool = False) -> None:
        """Delete commands from atuin history"""
        for cmd in commands:
            print(f"{'Would delete' if dry_run else 'Deleting'}: {cmd}")
            if not dry_run:
                try:
                    result = subprocess.run(
                        ["atuin", "search", cmd, "--delete"],
                        capture_output=True,
                        text=True
                    )
                    if result.returncode != 0:
                        print(f"Error deleting '{cmd}': {result.stderr}")
                except Exception as e:
                    print(f"Exception when deleting '{cmd}': {e}")
        
        print(f"{'Would have deleted' if dry_run else 'Deleted'} {len(commands)} commands")

    def automatic_cleaning(self, dry_run: bool = False, confirm: bool = True) -> None:
        """Run automatic cleaning based on predefined rules"""
        candidates = self.get_candidates_for_deletion()
        
        to_delete = []
        
        # 1. Always delete command not found
        to_delete.extend(candidates["not_found"])
        
        # 2. Delete invalid paths
        to_delete.extend(candidates["invalid_paths"])
        
        # 3. Delete high-confidence typos
        to_delete.extend(candidates["typos"])
        
        # Summary and confirmation
        print("\n=== AUTOMATIC CLEANING ===")
        print(f"Found {len(to_delete)} commands to delete:")
        print(f"- Command not found: {len(candidates['not_found'])}")
        print(f"- Invalid paths: {len(candidates['invalid_paths'])}")
        print(f"- Typos: {len(candidates['typos'])}")
        
        if not to_delete:
            print("No commands selected for deletion.")
            return
            
        # Execute deletion
        if not confirm or self.confirm(f"Delete {len(to_delete)} selected commands? THIS CANNOT BE UNDONE"):
            self.delete_commands(to_delete, dry_run)


def main():
    parser = argparse.ArgumentParser(description="Atuin History Cleaner")
    subparsers = parser.add_subparsers(dest="command", help="Command to run")
    
    # Analyze command
    analyze_parser = subparsers.add_parser("analyze", help="Analyze history")
    
    # Interactive command
    interactive_parser = subparsers.add_parser("interactive", help="Interactive cleaning")
    
    # Clean command
    clean_parser = subparsers.add_parser("clean", help="Automatic cleaning")
    clean_parser.add_argument("--dry-run", action="store_true", help="Don't actually delete anything")
    clean_parser.add_argument("--confirm", action="store_true", help="Ask for confirmation before deletion")
    
    args = parser.parse_args()
    
    cleaner = AtuinHistoryCleaner()
    
    if args.command == "analyze":
        stats = cleaner.analyze_history()
        cleaner.print_analysis(stats)
    elif args.command == "interactive":
        cleaner.run_interactive_cleaning()
    elif args.command == "clean":
        cleaner.automatic_cleaning(dry_run=args.dry_run, confirm=args.confirm)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()