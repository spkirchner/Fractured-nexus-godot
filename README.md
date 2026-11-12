# Fractured Nexus — Godot web-build experiment

This is an isolated feasibility prototype, not the live game. Contains two distinct GLB assets.

## Build automatically
Create a GitHub repository, upload these files at the repository root (including `.github/workflows/godot-web.yml`), and trigger **Actions → Godot Web Export → Run workflow**. The build uses `barichello/godot-ci:4.3` and publishes a downloadable web export as a GitHub Actions artifact. It does **not** automatically host a public URL. A separate static host is needed to test on Android.

## Verification
Open the actual exported build and inspect male/female pose, materials, scale, and controls. Equipment loading needs separately sourced equipment GLBs and attachment validation. No Supabase integration is included.

The model binaries were taken from the previous Fractured Nexus prototype package; their identity and pose must be confirmed visually.
