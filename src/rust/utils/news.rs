use std::process::Command;
use std::collections::HashSet;

struct Source {
    name: &'static str,
    url: &'static str,
}

fn unescape_html(s: &str) -> String {
    s.replace("&quot;", "\"")
     .replace("&amp;", "&")
     .replace("&lt;", "<")
     .replace("&gt;", ">")
     .replace("&#39;", "'")
     .replace("&rsquo;", "'")
     .replace("&lsquo;", "'")
     .replace("&ndash;", "-")
     .replace("&mdash;", "-")
}

fn fetch_headlines(url: &str, seen: &mut HashSet<String>, count: usize) -> Vec<String> {
    let output = Command::new("curl")
        .args(&["-s", "-L", "-A", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36", url])
        .output();

    let mut headlines = Vec::new();
    let noise = ["sign in", "privacy", "copyright", "advertisement", "read more", "follow us", "cookie", "login", "register", "terms of use", "contact us"];
    let ui_noise = ["metro station", "karol bagh"];

    if let Ok(out) = output {
        let html_text = String::from_utf8_lossy(&out.stdout);
        
        // Simple regex-like logic using string patterns for suckless parsing
        // We look for text between tags like <h1>...</h1> or <a>...</a>
        let tags = ["h1", "h2", "h3", "h4", "a"];
        
        for tag in tags.iter() {
            let start_tag = format!("<{}", tag);
            let end_tag = format!("</{}>", tag);
            
            let mut remaining = &html_text[..];
            while let Some(start_idx) = remaining.find(&start_tag) {
                let after_start = &remaining[start_idx..];
                if let Some(close_bracket) = after_start.find('>') {
                    let content_start = &after_start[close_bracket + 1..];
                    if let Some(end_idx) = content_start.find(&end_tag) {
                        let raw_text = &content_start[..end_idx];
                        
                        // Clean text: remove nested tags
                        let mut clean_text = String::new();
                        let mut inside_tag = false;
                        for c in raw_text.chars() {
                            if c == '<' { inside_tag = true; }
                            else if c == '>' { inside_tag = false; }
                            else if !inside_tag { clean_text.push(c); }
                        }
                        
                        let text = unescape_html(clean_text.trim());
                        let lower = text.to_lowercase();

                        if text.len() > 35 && text.len() < 180 && !seen.contains(&text) {
                            if !noise.iter().any(|n| lower.contains(n)) && !ui_noise.iter().any(|n| lower.contains(n)) {
                                headlines.push(text.clone());
                                seen.insert(text);
                                if headlines.len() >= count { return headlines; }
                            }
                        }
                        remaining = &content_start[end_idx..];
                    } else { break; }
                } else { break; }
            }
        }
    }
    headlines
}

fn main() {
    let sources = [
        Source { name: "Global", url: "https://www.bbc.com/news" },
        Source { name: "India", url: "https://www.indiatoday.in/india" },
        Source { name: "Assam", url: "https://assamtribune.com/assam" },
        Source { name: "Exam Prep", url: "https://www.jagranjosh.com/current-affairs" },
    ];

    println!("{:=<70}", "");
    println!(" TOP NEWS HEADLINES (RUST PORT)");
    println!("{:=<70}\n", "");

    let mut seen = HashSet::new();
    let mut total = 0;

    for source in sources.iter() {
        println!("--- {} ---", source.name);
        let lines = fetch_headlines(source.url, &mut seen, 10);
        if lines.is_empty() {
            println!("No headlines found (check connection or source).");
        }
        for (i, h) in lines.iter().enumerate() {
            println!("{}. {}", i + 1, h);
            total += 1;
        }
        println!();
    }
    println!("Total Unique Headlines: {}", total);
}
