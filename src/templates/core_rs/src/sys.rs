use libc;

pub fn check_process_id() {
    unsafe {
        let pid = libc::getpid();
        println!("[SYS] Current Process ID: {}", pid);
    }
}
