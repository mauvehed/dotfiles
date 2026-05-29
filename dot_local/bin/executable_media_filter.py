#!/usr/bin/env python3
"""
Media Duration Filter - Scan media files and move short clips to a separate folder.

Usage:
    python media_filter.py                    # Preview (dry-run)
    python media_filter.py --threshold 30     # Custom threshold in seconds
    python media_filter.py --execute          # Actually move files
    python media_filter.py --execute --output /path/to/folder
"""

import argparse
import subprocess
import json
import shutil
import sys
from pathlib import Path

MEDIA_EXTENSIONS = {'.mp4', '.mkv', '.avi', '.mov', '.m4v', '.wmv', '.m2ts', '.flv'}


def get_duration(filepath: Path) -> float | None:
    """Use ffprobe to get media duration in seconds. Returns None on error."""
    try:
        result = subprocess.run(
            ['/home/linuxbrew/.linuxbrew/bin/ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_format', str(filepath)],
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.returncode != 0:
            return None
        data = json.loads(result.stdout)
        return float(data['format']['duration'])
    except (subprocess.TimeoutExpired, json.JSONDecodeError, KeyError, ValueError):
        return None


def format_duration(seconds: float) -> str:
    """Format seconds as HH:MM:SS."""
    hours, remainder = divmod(int(seconds), 3600)
    minutes, secs = divmod(remainder, 60)
    if hours > 0:
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    return f"{minutes:02d}:{secs:02d}"


def format_size(bytes_size: int) -> str:
    """Format bytes as human-readable size."""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_size < 1024:
            return f"{bytes_size:.1f} {unit}"
        bytes_size /= 1024
    return f"{bytes_size:.1f} PB"


def scan_media_files(directory: Path, recursive: bool = False) -> list[Path]:
    """Find all media files in directory."""
    files = []
    if recursive:
        for f in directory.rglob('*'):
            if f.is_file() and f.suffix.lower() in MEDIA_EXTENSIONS and '.sync' not in f.parts:
                files.append(f)
    else:
        for f in directory.iterdir():
            if f.is_file() and f.suffix.lower() in MEDIA_EXTENSIONS:
                files.append(f)
    return sorted(files, key=lambda x: str(x).lower())


def main():
    parser = argparse.ArgumentParser(
        description='Scan media files and move short clips to a separate folder.'
    )
    parser.add_argument(
        '--threshold', '-t',
        type=int,
        default=60,
        help='Duration threshold in seconds (default: 60)'
    )
    parser.add_argument(
        '--output', '-o',
        type=Path,
        default=Path('./short_clips'),
        help='Destination folder for short clips (default: ./short_clips)'
    )
    parser.add_argument(
        '--execute',
        action='store_true',
        help='Actually move files (default is dry-run)'
    )
    parser.add_argument(
        '--recursive', '-r',
        action='store_true',
        help='Search subdirectories recursively'
    )
    parser.add_argument(
        '--file', '-f',
        type=Path,
        help='Check duration of a single file'
    )
    args = parser.parse_args()

    # Single file mode
    if args.file:
        filepath = args.file if args.file.is_absolute() else Path.cwd() / args.file
        if not filepath.exists():
            print(f"File not found: {filepath}")
            return
        duration = get_duration(filepath)
        if duration is None:
            print(f"Could not read duration: {filepath.name}")
        else:
            size = filepath.stat().st_size
            print(f"{format_duration(duration)} | {format_size(size)} | {filepath.name}")
        return

    directory = Path.cwd()
    print(f"Scanning media files in {directory}...")

    media_files = scan_media_files(directory, args.recursive)
    print(f"Found {len(media_files)} media files\n")

    if not media_files:
        print("No media files found.")
        return

    short_files = []
    errors = []

    print("Analyzing durations...")
    for i, filepath in enumerate(media_files, 1):
        print(f"\r  Processing {i}/{len(media_files)}: {filepath.name[:50]}...", end='', flush=True)
        duration = get_duration(filepath)
        if duration is None:
            errors.append(filepath)
        elif duration < args.threshold:
            size = filepath.stat().st_size
            short_files.append((filepath, duration, size))

    print("\r" + " " * 80 + "\r", end='')  # Clear progress line

    # Sort by duration
    short_files.sort(key=lambda x: x[1])

    # Display results
    if short_files:
        print(f"\nFiles under {args.threshold} seconds:")
        print(f"  {'Duration':<10} | {'Size':<10} | Filename")
        print(f"  {'-'*10} | {'-'*10} | {'-'*50}")

        total_size = 0
        for filepath, duration, size in short_files:
            total_size += size
            print(f"  {format_duration(duration):<10} | {format_size(size):<10} | {filepath.name}")

        print(f"\nSummary:")
        print(f"  Total files scanned: {len(media_files)}")
        print(f"  Files under threshold: {len(short_files)}")
        print(f"  Total size to move: {format_size(total_size)}")
        if errors:
            print(f"  Errors (could not read): {len(errors)}")
    else:
        print(f"\nNo files found under {args.threshold} seconds.")
        print(f"  Total files scanned: {len(media_files)}")
        if errors:
            print(f"  Errors (could not read): {len(errors)}")

    # Show errors if any
    if errors:
        print(f"\nFiles that could not be analyzed:")
        for filepath in errors:
            print(f"  - {filepath.name}")

    # Execute or show dry-run message
    if short_files:
        if args.execute:
            print(f"\nMoving {len(short_files)} files to {args.output}...")
            args.output.mkdir(parents=True, exist_ok=True)

            moved = 0
            skipped = 0
            for filepath, duration, size in short_files:
                # Preserve directory structure relative to source
                rel_path = filepath.relative_to(directory)
                dest = args.output / rel_path
                dest.parent.mkdir(parents=True, exist_ok=True)
                if dest.exists():
                    print(f"  Skipping (exists): {rel_path}")
                    skipped += 1
                else:
                    shutil.move(str(filepath), str(dest))
                    moved += 1

            print(f"\nDone! Moved {moved} files.")
            if skipped:
                print(f"Skipped {skipped} files (already exist in destination).")
        else:
            print(f"\nDry-run mode. Run with --execute to move these files to {args.output}")


if __name__ == '__main__':
    main()
