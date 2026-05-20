/// System and OS Logic Reference
use std::process::Command;
use std::fs::File;
use std::io::{Write, Read};
use std::path::Path;

pub fn file_io() -> std::io::Result<()> {
    let path = Path::new("offline_test.log");
    
    // Write
    let mut file = File::create(path)?;
    file.write_all(b"Offline data
")?;

    // Read
    let mut contents = String::new();
    File::open(path)?.read_to_string(&mut contents)?;
    
    Ok(())
}

pub fn command_execution() {
    let output = Command::new("ls")
        .arg("-a")
        .output()
        .expect("failed to execute process");

    if output.status.success() {
        let _s = String::from_utf8_lossy(&output.stdout);
    }
}

pub fn libc_usage() {
    // Basic libc usage for "suckless" / low level needs
    unsafe {
        let _pid = libc::getpid();
        // println!("PID via libc: {}", pid);
    }
}
