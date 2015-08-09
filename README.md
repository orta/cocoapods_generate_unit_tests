# cocoapods_generate_unit_tests

An experiment in scripting an entirely runnable xcodeproject + tests in ruby.

## Setup

``` sh
git clone https://github.com/orta/cocoapods_generate_unit_tests.git
cd cocoapods_generate_unit_tests
bundle install
```

## Running

``` sh
bundle exec ruby generate.rb
```

It will generate a collection of files in `./lib`. The end goal being that you can open the generated xcodeproj and run the units tests ( or via the terminal with `xcodebuild`.)
