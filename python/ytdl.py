#!/usr/bin/env python3

import sys
import subprocess
import argparse
from dataclasses import dataclass


@dataclass
class Config:
    audio_only: bool = False
    quality: int = 480
    output: str = "%(title)s.%(ext)s"


class YTDLDownloader:
    def __init__(self, config: Config):
        self.config = config

    def build_command(self, url: str):
        if self.config.audio_only:
            return [
                "yt-dlp",
                "-f", "bestaudio",
                "-x",
                "--audio-format", "mp3",
                "-o", self.config.output,
                url
            ]

        fmt = (
            f"bestvideo[height<={self.config.quality}][ext=mp4]+bestaudio[ext=m4a]"
            f"/best[height<={self.config.quality}][ext=mp4]"
        )

        return [
            "yt-dlp",
            "-f", fmt,
            "--merge-output-format", "mp4",
            "-o", self.config.output,
            url
        ]

    def download(self, url: str):
        cmd = self.build_command(url)
        subprocess.run(cmd, check=True)


def parse_args():
    parser = argparse.ArgumentParser(description="Flexible yt-dlp wrapper")
    parser.add_argument("urls", nargs="*", help="YouTube URLs")
    parser.add_argument("-a", "--audio", action="store_true",
                        help="download audio only")
    parser.add_argument("-q", "--quality", type=int, default=480,
                        help="max video height")
    parser.add_argument("-o", "--output", default="%(title)s.%(ext)s",
                        help="output filename template")

    return parser.parse_args()


def read_urls(cli_urls):
    if cli_urls:
        return cli_urls

    urls = []
    for line in sys.stdin:
        line = line.strip()
        if line:
            urls.append(line)
    return urls


def main():
    args = parse_args()

    config = Config(
        audio_only=args.audio,
        quality=args.quality,
        output=args.output
    )

    downloader = YTDLDownloader(config)

    urls = read_urls(args.urls)

    if not urls:
        print("Usage: ytdl.py <url> [url...]")
        sys.exit(1)

    for url in urls:
        downloader.download(url)


if __name__ == "__main__":
    main()
