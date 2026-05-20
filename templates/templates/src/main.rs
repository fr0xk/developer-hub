use anyhow::Result;
mod data;
mod sys;

#[tokio::main]
async fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().collect();

    if args.len() < 2 {
        println!("Usage: core_rs <name>");
        return Ok(());
    }

    let user = data::User::new(&args[1]);
    user.save("user.json")?;

    sys::check_process_id();

    println!("[+] Tool initialized for: {}", user.name);
    Ok(())
}
