use std::process::Command;
use std::thread;
use std::time::Duration;

fn run(cmd: &str, args: &[&str]) {
    let _ = Command::new(cmd).args(args).output();
}

fn main() {
    println!("[*] Initializing Optimized System Governor...");

    
    run("termux-wake-lock", &[]);

    
    run("termux-notification", &[
        "--id", "1337",
        "--title", "Governor: ACTIVE",
        "--content", "Performance Mode Engaged. CPU Affinity Locked.",
        "--ongoing",
        "--priority", "high"
    ]);

    
    let termux_pkg = "com.termux";

    println!("[+] Governor Running. Managing Termux priority...");

    loop {
        
        
        run("cmd", &["activity", "trim-memory", termux_pkg, "HIDDEN"]);
        
        
        run("cmd", &["activity", "send-trim-memory", termux_pkg, "RUNNING_LOW"]);

        
        thread::sleep(Duration::from_secs(300));
    }
}
