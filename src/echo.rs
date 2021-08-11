use std::process::Stdio;
pub fn echo(msg: &str) -> Result<(), String> {
    let echo = match which::which("echo") {
        Ok(echo) => Ok(echo),
        Err(_) => {
            let cwd = std::env::current_dir()
                .map_err(|err| format!("Error when finding current working directory: {}", err))?;
            let echobin = cwd.join("echo");
            if echobin.exists() {
                Ok(echobin)
            } else {
                Err("Could not find echo binary.".to_owned())
            }
        }
    }?;
    let child = std::process::Command::new(&echo)
        .args(vec![msg])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|err| format!("Could not run echo.\nError:\n{}", err))?;
    let output = child
        .wait_with_output()
        .map_err(|e| format!("Could wait for speedtest execution.\nError:\n{}", e))?;
    if output.status.success() {
        println!(
            "Output:{}",
            String::from_utf8_lossy(&output.stdout).to_string()
        );
        Ok(())
    } else {
        let stdout_text = String::from_utf8_lossy(&output.stdout);
        let error_message = if stdout_text.is_empty() {
            format!(
                "Echo executable exited with an error and no output. Errors:\n{}",
                String::from_utf8_lossy(&output.stderr)
            )
        } else {
            format!(
                "Echo executable exited with an error. Output:\n{}\nErrors:\n{}",
                stdout_text,
                String::from_utf8_lossy(&output.stderr)
            )
        };
        Err(error_message)
    }
}
