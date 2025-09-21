# Usage of JPMS

## Build jar 

```shell
./gradlew build
```

## Run it as Java Module
```shell
java --module-path build/libs/jlink-simple-demo-1.0-SNAPSHOT.jar --module jlink.simple.demo.main/com.github.siwonpawel.Main
```

## Build custom JVM

### jdeps

```shell
jdeps --recursive \
  --multi-release 21  \
  --print-module-deps \
  build/libs/jlink-simple-demo-1.0-SNAPSHOT.jar > build/deps.info
```

### jlink

```shell
jlink --verbose \
  --add-modules $(cat build/deps.info) \
  --strip-debug \
  --compress=2 \
  --no-header-files \
  --no-man-pages \
  --output build/customjre
```
