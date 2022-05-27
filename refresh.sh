cd ../overflow
flutter pub upgrade
cd - || exit

cd ../memory_tools
flutter pub upgrade
flutter pub run build_runner build --delete-conflicting-outputs
cd - || exit

cd ../dart-leaks
flutter pub upgrade
cd - || exit
