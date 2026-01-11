use tauri_plugin_shell::ShellExt;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_log::Builder::new().build())
        .setup(|app| {
            #[cfg(not(dev))]
            {
                let shell = app.shell();
                let mut sidecar_cmd = shell.sidecar("publii_ex").unwrap();

                // Inject the necessary environment variables for Phoenix
                sidecar_cmd = sidecar_cmd
                    .env("PHX_SERVER", "true")
                    .env("PORT", "4000")
                    .env("SECRET_KEY_BASE", "LpI0L7v5x+vVnL4fX6vP4vL5vVnL4fX6vP4vL5vVnL4fX6vP4vL5vVnL4fX6vP4v");

                let (mut rx, _child) = sidecar_cmd
                    .spawn()
                    .expect("Failed to spawn publii_ex sidecar");

                tauri::async_runtime::spawn(async move {
                    while let Some(event) = rx.recv().await {
                        if let tauri_plugin_shell::process::CommandEvent::Stdout(line) = event {
                            println!("Sidecar: {}", String::from_utf8_lossy(&line));
                        }
                    }
                });
            }

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
