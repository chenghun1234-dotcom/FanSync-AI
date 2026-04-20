#!/bin/bash

# 1. Flutter SDK 다운로드 (캐시 활용을 위해 체크)
if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# 2. Path 설정
export PATH="$PATH:`pwd`/flutter/bin"

# 3. 플러터 설정 확인
flutter config --enable-web

# 4. 빌드 수행
echo "Starting Flutter Build..."
cd dashboard
flutter pub get
flutter build web --release

# 5. 완료
echo "Build Finished Successfully."
