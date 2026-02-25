#!/data/data/com.termux/files/usr/bin/sh

# Run the news fetcher with static compilation settings
CGO_ENABLED=0 go build -a -installsuffix cgo -o news-fetcher main.go
./news-fetcher