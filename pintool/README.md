# prot_count — PROT-Prefix Execution Counter

PIN tool that measures runtime execution frequency of PROT-prefixed (`0x36`)
instructions in binaries compiled by the ProtCC/Protean LLVM passes.

## Build

Requires [Intel PIN 3.x](https://www.intel.com/content/www/us/en/developer/articles/tool/pin-a-dynamic-binary-instrumentation-tool.html).

    cd pintool
    make PIN_ROOT=/path/to/pin-3.x
    # produces: obj-intel64/prot_count.so

## Usage

    # Compile your target with a PTeX mode
    clang -mllvm --x86-ptex=ct -O1 -o my_binary my_source.c

    # Run under PIN
    pin -t pintool/obj-intel64/prot_count.so -- ./my_binary [args]

    # Redirect output to a file
    pin -t pintool/obj-intel64/prot_count.so -- ./my_binary [args] > counts.txt

## Output format

    === PROT prefix execution counts ===
    Total:  1234567

    Per-function (descending):
      aes_encrypt                              987654
      aes_key_schedule                          45678
      main                                       1235

- **Total**: sum of PROT-prefixed instruction executions across the whole run.
- **Per-function**: executions within each function, sorted descending.

## Notes

- Only the main executable is instrumented; shared libraries are excluded.
- Detection works because ProtCC always emits `0x36` as the first byte of a
  PROT-prefixed instruction (`X86MCCodeEmitter.cpp:1291`).
- Use `--x86-ptex=sbox` to guarantee non-zero counts for any binary (sandbox
  mode prefixes every eligible instruction).

## Testing

Compile the smoke-test target with ProtCC (replace `/path/to/build` with your build directory):

    /path/to/build/bin/clang -mllvm --x86-ptex=sbox -O1 \
        -o pintool/test/test_target pintool/test/test_target.c

Then run the smoke test:

    PIN_ROOT=/path/to/pin pintool/test/run_test.sh

Expected: `PASS: total=<N>` with `secret_work` in the per-function output.
