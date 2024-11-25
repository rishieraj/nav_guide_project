#!/bin/bash
#
# A convenient script to run level 2 unit test (eg. integration test)
#
#    - Step 1 builds all packages (my_model and my_controller) with
#      the debug and code coverage flag added (i.e, -DCOVERAGE=1)
#
#    - Step 2 and 3 are just running the colcon test.  This will
#      trigger both the unit test and the integration test for both
#      my_model and my_controller colcon packages. Once step 3
#      passes, all code coverage data (*.gcda, *.gcov) have been
#      generated and we can proceed to generate the "tracefiles" (aka
#      .info files) from them using lcov in step 4.
#
#    - In step 4.1 we generate the code coverage report for my_model
#      by building the "test_coverage" CMake target.
#
#    - In step 4.2, we create the code coverage report for the
#      my_controller by calling the "generate_coverage_report.bash"
#      script that is part of my_controller.  (i.e., ros2 run
#      my_controller ....).  This script simply calls lcov to convert
#      the code coverage data (*.gcda, *.gcov) to the "tracefile"
#      file (*.info), which gets converted to html report by the
#      genhtml program.
#
#    - Finally in step 5, we combine these 2 independent "tracefile"
#      (.info) files, (one from my_model and one from my_contorller)
#      into one.  And then use genhtml to create the final code
#      coverage report.


set -xue -o pipefail

##############################
# 0. start from scratch
##############################
rm -rf build/ install/
set +u                          # stop checking undefined variable  
source /opt/ros/humble/setup.bash
set -u                          # re-enable undefined variable check

##############################
# 1. Build for test coverage
##############################
colcon build --cmake-args -DCOVERAGE=1
set +u                          # stop checking undefined variable  
source install/setup.bash
set -u                          # re-enable undefined variable check

##############################
# 2. run all tests
##############################
colcon test

##############################
# 3. generate individual coverage reports:
##############################
colcon build \
       --event-handlers console_cohesion+ \
       --packages-select my_model \
       --cmake-target "test_coverage" \
       --cmake-arg -DUNIT_TEST_ALREADY_RAN=1
MY_MODEL_COVERAGE_INFO=./build/my_model/test_coverage.info

