# campus_facility_mobile

A new Flutter project.

```
flutter create --org com.devplux --project-name campus_facility_mobile mobile
```

## Pairing the mobile with Flutter project

```
adb pair 192.168.8.183:43041

Enter pairing code: ..................
```

#### Show as "Successfully paired to 192.168............ : ......."

#### main Wireless debugging screen, look for:

IP address & Port

```
adb connect 192.168....... : .....
```

### Check the devices:

```
adb devices
```

### Run the flutter app

```
flutter run -d 192.168........ : .......
```

## Once the app stuck with issues,

```
flutter clean
flutter pub get
flutter run
```
