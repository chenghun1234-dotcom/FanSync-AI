#!/bin/bash

# 1. Exit on error
set -e

# 2. Download Flutter SDK (shallow clone for speed)
if [ ! -d "flutter" ]; then
  echo ">>> Downloading Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# 3. Setup Path
export PATH="$PATH:`pwd`/flutter/bin"
echo ">>> Flutter Version Check:"
flutter --version

# 4. Enable Web
flutter config --enable-web

# 5. Build
echo ">>> Building Dashboard..."
cd dashboard
flutter pub get
flutter build web --release --base-href /

# 6. Final verification
echo ">>> Build Artifacts Check:"
ls -F build/web/
