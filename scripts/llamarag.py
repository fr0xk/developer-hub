import argparse
import json
import math
import stat
import subprocess
import sys
from pathlib import Path
from typing import List

import requests
from duckduckgo_search import DDGS


"""
Minimal RAG using llama.cpp only.
Single backend for embedding and generation.
Optimized for low-RAM devices (e.g., Redmi 12C 4GB).
"""


# -----------------------------
# Declarative configuration
# -----------------------------

DEFAULT_RESULTS: int = 4
DEFAULT_THREADS: int = 4
DEFAULT_CTX: int = 2048
DEFAULT_CHUNKSIZE: int = 300
DEFAULT_TOPK: int = 4

FIRECRAWL_ENDPOINT: str = "https://api.firecrawl.dev/v0/scrape"
DEFAULT_KEYFILE: Path = Path.home() / ".config/rag/firecrawl.key"
REQUEST_TIMEOUT: int = 60


# -----------------------------
# Utilities
# -----------------------------


def load_api_key(path: Path) -> str:
    if not path.exists():
        sys.exit("API key file not found")

    mode = path.stat().st_mode
    if mode & (stat.S_IRWXG | stat.S_IRWXO):
        sys.exit("API key file permissions too open (require chmod 600)")

    return path.read_text().strip()


def cosine(a: List[float], b: List[float]) -> float:
    dot = sum(x * y for x, y in zip(a, b))
    norm_a = math.sqrt(sum(x * x for x in a))
    norm_b = math.sqrt(sum(x * x for x in b))
    if norm_a == 0 or norm_b == 0:
        return 0.0
    return dot / (norm_a * norm_b)


# -----------------------------
# Search and extraction
# -----------------------------


def search(query: str, limit: int) -> List[str]:
    urls: List[str] = []
    with DDGS() as ddgs:
        results = ddgs.text(query, max_results=limit)
        for r in results:
            href = r.get("href")
            if href:
                urls.append(href)
    return urls


def extract(url: str, api_key: str) -> str:
    headers = {
        "Authorization": "Bearer " + api_key,
        "Content-Type": "application/json",
    }
    payload = {"url": url, "formats": ["markdown"]}

    r = requests.post(
        FIRECRAWL_ENDPOINT,
        json=payload,
        headers=headers,
        timeout=REQUEST_TIMEOUT,
    )
    r.raise_for_status()
    return r.json().get("markdown", "")


def chunk(text: str, size: int) -> List[str]:
    words = text.split()
    return [
        " ".join(words[i:i + size])
        for i in range(0, len(words), size)
    ]


# -----------------------------
# llama.cpp embedding
# -----------------------------


def embed(model_path: str, text: str) -> List[float]:
    cmd = [
        "llama-embedding",
        "-m", model_path,
        "-p", text,
        "--json",
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())

    data = json.loads(result.stdout)
    return data["embedding"]


def rank(
    model_path: str,
    query: str,
    chunks: List[str],
    topk: int,
) -> List[str]:
    q_vec = embed(model_path, query)

    scored = []
    for c in chunks:
        c_vec = embed(model_path, c)
        sim = cosine(q_vec, c_vec)
        scored.append((sim, c))

    scored.sort(reverse=True, key=lambda x: x[0])
    return [x[1] for x in scored[:topk]]


# -----------------------------
# llama-cli generation
# -----------------------------


def generate(model_path: str, prompt: str, threads: int, ctx: int) -> str:
    cmd = [
        "llama-cli",
        "-m", model_path,
        "-t", str(threads),
        "-c", str(ctx),
        "-p", prompt,
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())

    return result.stdout


# -----------------------------
# Main
# -----------------------------


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Minimal RAG using llama.cpp only"
    )

    parser.add_argument("prompt", type=str)
    parser.add_argument("-m", "--model", required=True, type=str)

    parser.add_argument("-r", "--results", type=int, default=DEFAULT_RESULTS)
    parser.add_argument("-t", "--threads", type=int, default=DEFAULT_THREADS)
    parser.add_argument("-c", "--ctx", type=int, default=DEFAULT_CTX)
    parser.add_argument("-s", "--chunksize", type=int, default=DEFAULT_CHUNKSIZE)
    parser.add_argument("-k", "--topk", type=int, default=DEFAULT_TOPK)
    parser.add_argument(
        "-f",
        "--keyfile",
        type=str,
        default=str(DEFAULT_KEYFILE),
    )

    args = parser.parse_args()

    api_key = load_api_key(Path(args.keyfile).expanduser())

    urls = search(args.prompt, args.results)

    corpus: List[str] = []
    for url in urls:
        try:
            text = extract(url, api_key)
            if text:
                corpus.append(text)
        except Exception:
            continue

    if not corpus:
        sys.exit("No content retrieved")

    text = "\n".join(corpus)
    chunks = chunk(text, args.chunksize)

    selected = rank(
        model_path=args.model,
        query=args.prompt,
        chunks=chunks,
        topk=args.topk,
    )

    context = "\n\n".join(selected)
    final_prompt = context + "\n\n" + args.prompt

    output = generate(
        model_path=args.model,
        prompt=final_prompt,
        threads=args.threads,
        ctx=args.ctx,
    )

    print(output)


if __name__ == "__main__":
    main()
