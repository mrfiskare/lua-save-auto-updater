# PS5 Jailbreak Lua Save File Update Script

This tool automates the process of updating the Lua save files on your jailbroken PlayStation 5. It is designed to assist users who utilize the **etaHEN** exploit and want to switch or update their Lua loaders safely via FTP.

> ⚠️ **WARNING**  
> This script **modifies files on your PS5's internal storage**. Misuse may result in data loss or corruption of your exploit environment. **BACK UP YOUR FILES** before using this tool.  
> Use at your own risk.

---

## ⚙️ Features

- Ensures you've acknowledged the risks and confirmed backups.
- Automatically checks for and installs `lftp` if missing.
- Validates PS5 IP address and FTP port input.
- Lets you choose between two popular Lua loaders:
  - [`itsPLK/ps5_lua_loader`](https://github.com/itsPLK/ps5_lua_loader) (Recommended)
  - [`shahrilnet/remote_lua_loader`](https://github.com/shahrilnet/remote_lua_loader)
- Establishes FTP connection to your PS5 and uploads the loader files.
- Monitors `/mnt/pfs` for a `savedata` directory.
- Automatically detects when it's writable and uploads the updated Lua files.

---

## 🧰 Prerequisites

- A **jailbroken PS5** with **FTP access enabled** (e.g., via etaHEN).
- **Git** installed (for cloning the loader).
- **PowerShell** (comes with Windows).
- Internet connection (to fetch `lftp` and loader).

---

## 🚀 Usage

1. **Download or clone** this repository.
2. **Run the script**: Double-click `ps5_loader_update.bat` or execute from command line.
3. **Follow the prompts**:
   - Confirm backup and accept the disclaimer.
   - Input your PS5's IP address and FTP port (default is `1337`).
   - Choose which Lua loader to use.
4. The script will:
   - Connect to your PS5.
   - Reset `/data/lua-tmp` and upload the loader.
   - Detect the active `savedata` folder.
   - Wait for it to become writable.
   - Upload the necessary Lua files.

---

## 🧪 Tested On

- Windows 11
- etaHEN-enabled PS5
- PowerShell 5+

---

## ❗ Disclaimer

This tool is intended for educational and development purposes only.  
Neither the creator nor contributors are responsible for any damage or misuse.

---

## 📄 License

This project is released under the [MIT License](LICENSE).