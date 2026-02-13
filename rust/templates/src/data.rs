use serde::{Serialize, Deserialize};
use anyhow::Result;
use std::fs::File;

#[derive(Serialize, Deserialize, Debug)]
pub struct User {
    pub name: String,
    pub active: bool,
}

impl User {
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            active: true,
        }
    }

    pub fn save(&self, path: &str) -> Result<()> {
        let file = File::create(path)?;
        serde_json::to_writer_pretty(file, self)?;
        Ok(())
    }
}
