# Zen Browser - Disable Workspace Switching Animations

Disables the sliding animations when switching between workspaces in Zen Browser's sidebar.

## Installation

1. **Find your Zen Browser profile directory:**
   - Linux: `~/.zen/[profile-name]/chrome/`
   - Windows: `%APPDATA%\Zen\Profiles\[profile-name]\chrome\`
   - macOS: `~/Library/Application Support/Zen/Profiles/[profile-name]/chrome/`
  
(Alternatively, complete step 1 here: [docs.zen-browser.app/guides/manage-profiles#1](https://docs.zen-browser.app/guides/manage-profiles#1-open-your-current-profile-folder)

2. **Create chrome directory if it doesn't exist:**
   ```bash
   mkdir -p ~/.zen/[your-profile]/chrome/
   ```

3. **Copy or append the CSS:**
   - If you don't have a `userChrome.css` file, copy the provided one
   - If you already have one, append the contents to your existing file

4. **Enable userChrome.css in Zen Browser:**
   - Open Zen Browser
   - Go to `about:config`
   - Search for `toolkit.legacyUserProfileCustomizations.stylesheets`
   - Set it to `true`
   - Restart Zen Browser

## Tested on

- Zen Browser (Release channel)
- Linux (Ubuntu)
