#

## DEBIAN
# sudo apt update && sudo apt install -y openjdk-17-jdk libgtk-3-dev clang mesa-utils
# export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
# export ANDROID_HOME=$HOME/Projects/flatter/android-sdk
# export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools


## FEDORA
sudo dnf install -y java-17-openjdk-devel gtk3-devel clang glx-utils
sudo dnf install -y cmake gcc-c++ pkg-config
sudo dnf install -y android-tools
sudo dnf install adoptium-temurin-java-repository
sudo dnf install temurin-17-jdk

# export JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
export JAVA_HOME=~/Projects/flatter/jdk17;
export ANDROID_HOME=$HOME/Projects/flatter/android-sdk
export PATH=$PATH:~/Projects/flatter/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools


export ANDROID_HOME=/home/human/Projects/flatter/android-sdk
export JAVA_HOME=/home/human/Projects/flatter/jdk17
export PATH=$PATH:/home/human/Projects/flatter/flutter/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin

# flutter config --jdk-dir is already saved globally, so Gradle builds get JDK 17 even if JAVA_HOME isn't set — but keep it for other Gradle/CLI use.

# flutter build apk --debug → ✓ Built app-debug.apk. flutter run -d ZY22FPHBVB should now work.



# export JAVA_HOME=/home/human/Projects/flatter/jdk17; 
# export ANDROID_HOME=/home/human/Projects/flatter/android-sdk; 
# export PATH=$PATH:/home/human/Projects/flatter/flutter/bin:$ANDROID_HOME/platform-tools; 
# cd /home/human/Projects/flatter/fishbowl && flutter build apk --debug 2>&1 | tail -40

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"


# tell Flutter explicitly (writes to flutter config, survives shells)
flutter config --jdk-dir="/usr/lib/jvm/java-17-openjdk"