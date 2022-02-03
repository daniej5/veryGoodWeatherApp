# Very Good Weather App

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]

A very good weather app for [Very Good Ventures][very_good_ventures_link].

*Built by [Jonathan Daniels][jonathan_daniels_link].*

---

## Getting Started 🚀

To run the project on an iOS or Android device:
  1. Run the command to find your device id:
```sh
$ flutter devices
```
  2. Copy the device id you want to use then run then following command with the device id
```sh
$ flutter run -d <deviceID>
```

This project is not supported on web or desktop.

---

## Running Tests 🧪

To run all unit and widget tests use the following command:

```sh
$ flutter test --coverage
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_ventures_link]: https://verygood.ventures/
[jonathan_daniels_link]: https://jonathandaniels.info/