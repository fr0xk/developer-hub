/// Asynchronous Logic with Tokio
use tokio::sync::mpsc;
use tokio::time::{sleep, Duration};

pub async fn run_async_flow() {
    let (tx, mut rx) = mpsc::channel(32);

    let tx_clone = tx.clone();
    tokio::spawn(async move {
        sleep(Duration::from_millis(100)).await;
        tx_clone.send("Task 1 Done").await.unwrap();
    });

    tokio::spawn(async move {
        tx.send("Task 2 Done").await.unwrap();
    });

    while let Some(msg) = rx.recv().await {
        // println!("Recv: {}", msg);
        if msg == "Task 1 Done" { break; }
    }
}
