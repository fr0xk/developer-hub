#!/usr/bin/env python3
import os
import sys
import subprocess


NOTES_DIR = os.path.expanduser("~/notes")
MODEL_PATH = os.path.expanduser("~/.models/RWKV-7-World-1.5B-v2-20250128-Ctx4096-Q4_K_M.gguf")

def get_context(query):
    context = []
    if not os.path.exists(NOTES_DIR):
        return ""
    
    
    keywords = [w.lower() for w in query.split() if len(w) > 3]
    for root, _, files in os.walk(NOTES_DIR):
        for file in files:
            if file.endswith(".txt"):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                    if any(k in content.lower() for k in keywords):
                        context.append(f"--- Context from {file} ---\n{content}")
    
    return "\n".join(context)

def main():
    if len(sys.argv) < 2:
        print("Usage: rag 'your question'")
        return

    if not os.path.exists(MODEL_PATH):
        print(f"[!] Error: Model not found at {MODEL_PATH}")
        print("[*] Please run 'python3 ~/scripts/get_latest_rwkv.py' first.")
        return

    query = sys.argv[1]
    context = get_context(query)
    
    prompt = f"Context:\n{context}\n\nQuestion: {query}\n\nAnswer based on context:"
    
    
    cmd = [
        "llama-cli",
        "-m", MODEL_PATH,
        "-c", "4096",
        "-t", "4",
        "--temp", "0",
        "-cnv",
        "--chat-template", "rwkv-world",
        "-p", prompt
    ]
    
    subprocess.run(cmd)

if __name__ == "__main__":
    main()
