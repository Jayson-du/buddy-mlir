func private @zero() -> index {
  %0 = arith.constant 0 : index
  return %0 : index
}

func @main() {
  %c0 = arith.constant 0.0 : f32
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  %c3 = arith.constant 3 : index

  %lb = arith.constant 0 : index
  %ub = arith.constant 9 : index

  %A = memref.alloc() : memref<9xf32>
  %U = memref.cast %A :  memref<9xf32> to memref<*xf32>

  // Initialize memref with zeros because we do load and store to in every test
  // to verify that we process each element of the iteration space once.
  scf.parallel (%i) = (%lb) to (%ub) step (%c1) {
    memref.store %c0, %A[%i] : memref<9xf32>
  }

  // 1. %i = (0) to (9) step (1)
  scf.parallel (%i) = (%lb) to (%ub) step (%c1) {
    %0 = arith.index_cast %i : index to i32
    %1 = arith.sitofp %0 : i32 to f32
    %2 = memref.load %A[%i] : memref<9xf32>
    %3 = arith.addf %1, %2 : f32
    memref.store %3, %A[%i] : memref<9xf32>
  }

  call @print_memref_f32(%U): (memref<*xf32>) -> ()

  scf.parallel (%i) = (%lb) to (%ub) step (%c1) {
    memref.store %c0, %A[%i] : memref<9xf32>
  }

  // 2. %i = (0) to (9) step (2)
  scf.parallel (%i) = (%lb) to (%ub) step (%c2) {
    %0 = arith.index_cast %i : index to i32
    %1 = arith.sitofp %0 : i32 to f32
    %2 = memref.load %A[%i] : memref<9xf32>
    %3 = arith.addf %1, %2 : f32
    memref.store %3, %A[%i] : memref<9xf32>
  }

  call @print_memref_f32(%U): (memref<*xf32>) -> ()

  scf.parallel (%i) = (%lb) to (%ub) step (%c1) {
    memref.store %c0, %A[%i] : memref<9xf32>
  }

  // 3. %i = (-20) to (-11) step (3)
  %lb0 = arith.constant -20 : index
  %ub0 = arith.constant -11 : index
  scf.parallel (%i) = (%lb0) to (%ub0) step (%c3) {
    %0 = arith.index_cast %i : index to i32
    %1 = arith.sitofp %0 : i32 to f32
    %2 = arith.constant 20 : index
    %3 = arith.addi %i, %2 : index
    %4 = memref.load %A[%3] : memref<9xf32>
    %5 = arith.addf %1, %4 : f32
    memref.store %5, %A[%3] : memref<9xf32>
  }

  call @print_memref_f32(%U): (memref<*xf32>) -> ()

  // 4. Check that loop with zero iterations doesn't crash at runtime.
  %lb1 = call @zero(): () -> (index)
  %ub1 = call @zero(): () -> (index)

  scf.parallel (%i) = (%lb1) to (%ub1) step (%c1) {
    %false = arith.constant 0 : i1
    assert %false, "should never be executed"
  }

  memref.dealloc %A : memref<9xf32>
  return
}

func private @print_memref_f32(memref<*xf32>) attributes { llvm.emit_c_interface }
