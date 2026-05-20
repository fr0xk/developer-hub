use clap::{Parser, Subcommand};
use handbook::*; // Using the lib modules

#[derive(Parser)]
#[command(author, version, about = "Offline Rust Reference Handbook")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Show basic syntax
    Basics,
    /// System and IO examples
    System,
    /// Async patterns
    Async,
    /// JSON and Serde
    Json,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Basics => {
            basics::ownership_demo();
            basics::pattern_matching();
        }
        Commands::System => {
            system::file_io()?;
            system::command_execution();
            system::libc_usage();
        }
        Commands::Async => {
            async_demo::run_async_flow().await;
        }
        Commands::Json => {
            serialization::json_demo();
        }
    }

    Ok(())
}
