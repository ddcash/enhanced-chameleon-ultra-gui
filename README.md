# Enhanced Chameleon Ultra GUI v2.0.0

An enhanced cross-platform Flutter application for the Chameleon Ultra with full Proxmark3 Iceman firmware compatibility and command interface.

## Features

### 🚀 Enhanced Terminal Interface
- **Proxmark3-compatible command line interface** with full command syntax support
- **Auto-completion** and **command history** for efficient operation
- **Real-time command execution** with proper error handling and output formatting
- **Built-in help system** with comprehensive command documentation

### 📡 Comprehensive RFID/NFC Operations

#### Low Frequency (LF) Commands
- `lf search` - Auto-detect and identify LF tags
- `lf hid read/clone` - HID Prox card operations
- `lf em410x read/clone` - EM410x card operations
- `lf t55xx read/write` - T55xx chip operations
- Full parameter support matching Proxmark3 syntax

#### High Frequency (HF) Commands
- `hf search` - Auto-detect and identify HF tags
- `hf 14a info/read/sim` - ISO14443A operations
- `hf mf rdbl/wrbl/dump/restore` - MIFARE Classic operations
- Advanced key recovery and nested attacks
- Complete compatibility with Proxmark3 workflows

#### Hardware Commands
- `hw version` - Device information and firmware details
- `hw tune` - Antenna tuning and optimization
- `hw status` - Real-time device status monitoring

#### Data Management
- `data plot/save/load/hex` - Signal analysis and data manipulation
- Multiple file format support (binary, hex, CSV, JSON)
- Graphical waveform visualization

### 🦎 Chameleon Ultra Specific Features
- **Advanced slot management** - `chameleon slot` commands
- **LED control** - `chameleon led` with color and brightness control
- **Battery monitoring** - `chameleon battery` status and health
- **Device configuration** - `chameleon config` settings management

### 🎨 Modern Flutter UI
- **Cross-platform support** (Android, iOS, Windows, macOS, Linux)
- **Dark/Light theme** support with system integration
- **Responsive design** optimized for phones, tablets, and desktop
- **Material 3** design language with intuitive navigation

## Installation

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Platform-specific development tools:
  - Android: Android Studio/SDK
  - iOS: Xcode (macOS only)
  - Desktop: Platform-specific build tools

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/ddcash/enhanced-chameleon-ultra-gui.git
   cd enhanced-chameleon-ultra-gui
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate launcher icons**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Usage

### Getting Started

1. **Launch the application** and navigate to the Terminal tab
2. **Connect to your Chameleon Ultra** using the connect button or `connect` command
3. **Start exploring** with `help` to see available commands

### Basic Command Examples

```bash
# Get device information
pm3> hw version

# Search for LF tags
pm3> lf search

# Read HID Prox card
pm3> lf hid read

# Clone EM410x card
pm3> lf em410x clone 1234567890

# Search for HF tags
pm3> hf search

# Get ISO14443A info
pm3> hf 14a info

# Read MIFARE block with key
pm3> hf mf rdbl b 4 k ffffffffffff

# Dump entire MIFARE card
pm3> hf mf dump

# Manage Chameleon slots
pm3> chameleon slot list
pm3> chameleon slot set 2

# Control LEDs
pm3> chameleon led color red
pm3> chameleon led brightness 128

# Check battery status
pm3> chameleon battery

# Device configuration
pm3> chameleon config list
pm3> chameleon config set animation false
```

### Advanced Operations

#### MIFARE Classic Workflow
```bash
# Search and identify card
pm3> hf search

# Get detailed information
pm3> hf 14a info

# Dump entire card with nested attack
pm3> hf mf dump k ffffffffffff

# Save dump to file
pm3> data save f mycard.bin

# Restore to another card
pm3> hf mf restore f mycard.bin
```

#### LF Clone Workflow
```bash
# Search for LF tag
pm3> lf search

# Read original card
pm3> lf em410x read

# Clone to T55xx
pm3> lf em410x clone 1234567890

# Verify clone
pm3> lf em410x read
```

### Terminal Features

- **Auto-completion**: Press Tab to complete commands
- **Command history**: Use Up/Down arrows to navigate history
- **Built-in help**: Type `help` or `help <category>` for assistance
- **Clear screen**: Use `clear` or `cls`
- **Connection management**: `connect`, `disconnect`, `status`

## Architecture

### Command System
The application features a modular command architecture:

```
lib/commands/
├── command_base.dart          # Base command interface
├── command_registry.dart      # Command registration and parsing
├── hw_commands.dart          # Hardware commands
├── lf_commands.dart          # Low frequency commands
├── hf_commands.dart          # High frequency commands
├── data_commands.dart        # Data manipulation commands
└── chameleon_commands.dart   # Chameleon-specific commands
```

### Communication Layer
```
lib/bridge/
├── chameleon_connector.dart     # Device connection management
└── chameleon_communicator.dart  # Protocol-level communication
```

### User Interface
```
lib/ui/
├── terminal_page.dart     # Main terminal interface
├── home_page.dart        # Device status and quick actions
├── card_manager_page.dart # Card slot management
├── tools_page.dart       # Additional tools and utilities
└── settings_page.dart    # Application settings
```

## Downloads

### 📦 Pre-built Releases

GitHub Actions automatically builds packages for all platforms:

- **📱 Android APK** - arm64-v8a, armeabi-v7a, x86_64
- **🪟 Windows** - Setup installer + Portable version  
- **🐧 Linux** - Portable tar.gz package
- **🍎 macOS** - DMG installer

**[Download Latest Release](https://github.com/ddcash/enhanced-chameleon-ultra-gui/releases)**

### 🔄 Development Builds

Automatic builds are created on every commit to main branch:

**[Download Development Build](https://github.com/ddcash/enhanced-chameleon-ultra-gui/releases/tag/dev)**

## Development

### Adding New Commands

1. **Create command class** extending `CommandBase`
2. **Implement required methods**: `execute()`, `getHelp()`, `validateArgs()`
3. **Register in CommandRegistry** within `_registerCommands()`

Example:
```dart
class MyCustomCommand extends CommandBase {
  @override
  String get command => 'my custom';

  @override
  String get category => 'custom';

  @override
  String get description => 'My custom command';

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    // Implementation here
    return CommandResult.success('Command executed successfully');
  }

  @override
  String getHelp() => 'Usage: my custom [parameters]';

  @override
  bool validateArgs(List<String> args) => true;
}
```

### Testing

Run tests with:
```bash
flutter test
```

### Building for Release

#### Android APK
```bash
flutter build apk --release
```

#### iOS App Store
```bash
flutter build ios --release
```

#### Desktop Applications
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## Compatibility

### Proxmark3 Command Compatibility
This application provides extensive compatibility with Proxmark3 Iceman firmware commands:

- ✅ Hardware commands (`hw version`, `hw tune`, `hw status`)
- ✅ LF commands (`lf search`, `lf hid`, `lf em410x`, `lf t55xx`)
- ✅ HF commands (`hf search`, `hf 14a`, `hf mf`)
- ✅ Data commands (`data plot`, `data save`, `data load`)
- ✅ Built-in terminal features (help, history, autocomplete)

### Chameleon Ultra Features
- ✅ All standard Chameleon Ultra operations
- ✅ Slot management and card emulation
- ✅ LED control and customization
- ✅ Battery monitoring and power management
- ✅ Device configuration and settings

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Implement your changes with tests
4. Submit a pull request with detailed description

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add documentation for public APIs
- Maintain consistency with existing command patterns

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Proxmark3 Iceman Firmware** for command reference and inspiration
- **GameTec-live/ChameleonUltraGUI** for the original Flutter foundation
- **Chameleon Ultra Team** for the amazing hardware platform
- **Flutter Team** for the excellent cross-platform framework

## Support

- 📖 Check the built-in help system: `help` command
- 🐛 Report bugs via GitHub Issues
- 💬 Join discussions in GitHub Discussions

---

**Enhanced Chameleon Ultra GUI v2.0.0** - Bringing Proxmark3 power to your mobile device! 🦎⚡