use serde_json::json;
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() {
    println!("[*] Starting complex dependency test...");

    
    let data = json!({
        "status": "active",
        "mode": "suckless",
        "runtime": "tokio"
    });

    println!("[+] Serialized Data: {}", data);

    
    sleep(Duration::from_secs(1)).await;
    
    println!("[+] Async wait complete. System functional.");
}
