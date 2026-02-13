/// Rust Basics Reference
/// Ownership, Borrowing, and Pattern Matching.

pub fn ownership_demo() {
    let s1 = String::from("hello");
    let s2 = s1; // s1 moved
    // println!("{}", s1); // Error

    let s3 = s2.clone(); // Deep copy
    let len = calculate_length(&s3); // Borrowing
    println!("Length of '{}' is {}", s3, len);
}

fn calculate_length(s: &String) -> usize {
    s.len()
}

pub fn pattern_matching() {
    enum ToolState {
        Idle,
        Running(u32),
        Error(String),
    }

    let state = ToolState::Running(42);

    match state {
        ToolState::Idle => println!("Idle"),
        ToolState::Running(pid) => println!("Running PID: {}", pid),
        ToolState::Error(ref e) => eprintln!("Err: {}", e),
    }

    // if let syntax
    if let ToolState::Running(p) = state {
        assert_eq!(p, 42);
    }
}
