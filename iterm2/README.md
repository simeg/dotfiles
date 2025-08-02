# iTerm2 Configuration Management

This directory contains iTerm2 configuration files for managing terminal settings.

## Files

- `com.googlecode.iterm2.plist` - Main iTerm2 preferences file
- `manage-iterm2.sh` - Script to export/import iTerm2 settings

## Usage

### Export current settings
```bash
./iterm2/manage-iterm2.sh export
```

### Import settings (restore from dotfiles)
```bash
./iterm2/manage-iterm2.sh import
```

### Sync settings (export current to dotfiles)
```bash
./iterm2/manage-iterm2.sh sync
```

## How it works

iTerm2 stores its settings in `~/Library/Preferences/com.googlecode.iterm2.plist`. This is a binary plist file that contains all your iTerm2 preferences including:

- Profiles (colors, fonts, key bindings)
- Window arrangements
- General preferences
- Hotkey settings

## Setting up on a new computer

When setting up dotfiles on a new machine:

1. **Install iTerm2** first (via Homebrew or direct download)
2. **Run the main dotfiles setup:** `make setup`
3. **Import iTerm2 settings:** `./iterm2/manage-iterm2.sh import`
4. **Restart iTerm2** to apply all settings

The iTerm2 settings are not automatically symlinked because macOS caches plist files, so manual import is required.

## Notes

- iTerm2 must be restarted after importing settings
- The symlink approach won't work for plist files since macOS caches them
- Always export your settings before making major changes