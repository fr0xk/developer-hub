package main

import (
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
	"time"
)

func unescapeHTML(s string) string {
	s = strings.ReplaceAll(s, "&quot;", "\"")
	s = strings.ReplaceAll(s, "&amp;", "&")
	s = strings.ReplaceAll(s, "&lt;", "<")
	s = strings.ReplaceAll(s, "&gt;", ">")
	s = strings.ReplaceAll(s, "&#39;", "'")
	s = strings.ReplaceAll(s, "&rsquo;", "'")
	s = strings.ReplaceAll(s, "&lsquo;", "'")
	s = strings.ReplaceAll(s, "&ndash;", "-")
	s = strings.ReplaceAll(s, "&mdash;", "-")
	return s
}

func fetchHeadlines(url string, seen map[string]bool, count int) []string {
	client := &http.Client{
		Timeout: 10 * time.Second,
	}
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return []string{}
	}
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36")

	resp, err := client.Do(req)
	if err != nil {
		return []string{}
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return []string{}
	}

	html := string(body)
	var headlines []string

	// Simple tag-based parsing for h1, h2, h3, h4, a tags
	tags := []string{"h1", "h2", "h3", "h4", "a"}
	noise := []string{
		"sign in", "privacy", "copyright", "advertisement", "read more",
		"follow us", "cookie", "login", "register", "terms of use", "contact us",
	}
	uiNoise := []string{"metro station", "karol bagh"}

	for _, tag := range tags {
		pattern := fmt.Sprintf("<%s[^>]*>(.*?)</%s>", tag, tag)
		re := regexp.MustCompile(pattern)
		matches := re.FindAllStringSubmatch(html, -1)

		for _, match := range matches {
			if len(match) < 2 {
				continue
			}
			rawText := match[1]

			// Clean text: remove nested tags
			cleanText := regexp.MustCompile(`<[^>]*>`).ReplaceAllString(rawText, "")
			text := strings.TrimSpace(unescapeHTML(cleanText))

			if len(text) > 35 && len(text) < 180 {
				lower := strings.ToLower(text)
				isNoise := false

				for _, n := range noise {
					if strings.Contains(lower, n) {
						isNoise = true
						break
					}
				}
				if !isNoise {
					for _, n := range uiNoise {
						if strings.Contains(lower, n) {
							isNoise = true
							break
						}
					}
				}

				if !isNoise && !seen[text] {
					headlines = append(headlines, text)
					seen[text] = true
					if len(headlines) >= count {
						return headlines
					}
				}
			}
		}
	}

	return headlines
}

func main() {
	sources := []struct {
		name string
		url  string
	}{
		{"Global", "https://www.bbc.com/news"},
		{"India", "https://www.indiatoday.in/india"},
		{"Assam", "https://assamtribune.com/assam"},
		{"Exam Prep", "https://www.jagranjosh.com/current-affairs"},
	}

	fmt.Println(strings.Repeat("=", 70))
	fmt.Println(" TOP NEWS HEADLINES (GO PORT)")
	fmt.Println(strings.Repeat("=", 70))
	fmt.Println()

	seen := make(map[string]bool)
	total := 0

	for _, source := range sources {
		fmt.Printf("--- %s ---\n", source.name)
		lines := fetchHeadlines(source.url, seen, 10)
		if len(lines) == 0 {
			fmt.Println("No headlines found (check connection or source).")
		}
		for i, h := range lines {
			fmt.Printf("%d. %s\n", i+1, h)
			total++
		}
		fmt.Println()
	}

	fmt.Printf("Total Unique Headlines: %d\n", total)
}