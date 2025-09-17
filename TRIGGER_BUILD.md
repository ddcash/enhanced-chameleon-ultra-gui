# 🚀 Trigger Build

This commit will trigger the GitHub Actions workflow to build packages for all platforms.

## 📦 Expected Build Outputs

### Android
- APK files for arm64-v8a, armeabi-v7a, x86_64
- App Bundle for Google Play Store

### Windows  
- NSIS Setup Installer
- Portable ZIP package

### Linux
- Portable tar.gz package

### macOS
- DMG installer

## 🔄 Build Process

The builds will be available as:
1. **Development Release** - Auto-created for main branch commits
2. **Tagged Release** - Created when you push a version tag (e.g., v2.0.0)

## 📖 Next Steps

1. Wait for builds to complete (~10-15 minutes)
2. Download builds from the Releases page
3. Test on your target platforms
4. Create a tagged release when ready for distribution

---

🤖 Generated with [Claude Code](https://claude.ai/code)