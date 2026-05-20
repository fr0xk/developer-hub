/// Serialization/Deserialization with Serde
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
struct ToolConfig {
    name: String,
    version: u32,
    enabled: bool,
}

pub fn json_demo() {
    let config = ToolConfig {
        name: "MyTool".to_string(),
        version: 1,
        enabled: true,
    };

    // Serialize
    let j = serde_json::to_string(&config).unwrap();

    // Deserialize
    let decoded: ToolConfig = serde_json::from_str(&j).unwrap();
    assert_eq!(decoded.version, 1);
}
