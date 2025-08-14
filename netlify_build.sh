#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK (cached between builds if present)
if [ ! -d "$HOME/flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone -b ${FLUTTER_VERSION:-stable} https://github.com/flutter/flutter.git "$HOME/flutter"
else
  echo "Flutter SDK already present at $HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter doctor -v

# Netlify already sets working directory to the base (cube_bld_mercator)
echo "Working directory: $(pwd)"

flutter pub get
# If deploying under a sub-path, set: --base-href "/your-subpath/"
flutter build web --release
