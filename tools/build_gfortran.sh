# Build gfortran binary against OpenBLAS

set -ex

rm -rf for_test
mkdir for_test
cd for_test

repo_path=$(cygpath "$START_DIR")
OBP=$(cygpath $OPENBLAS_ROOT\\$BUILD_BITS)

dynamic_libname=$(find $OBP/lib -maxdepth 1 -type f -name '*.dll.a' | tail -1)
dll_name=$(find $OBP/bin -maxdepth 1 -type f -name '*.dll' | tail -1)

grep dpotrf $OBP/include/*
nm $dynamic_libname | grep dpotrf

cp $dll_name .

# Only the DLL ships in the wheel (see build_prepare_wheel.sh / windows.yml),
# so we only test linking against it, not against a static library.
if [ "$INTERFACE64" == "1" ]; then
  gfortran -I $OBP/include -fdefault-integer-8 -o test_dyn.exe ${repo_path}/test64_.f90 $dynamic_libname
else
  gfortran -I $OBP/include -o test_dyn.exe ${repo_path}/test.f90 $dynamic_libname
fi
