; 3. Public value flowing across a backedge (loop counter).
;    Loop induction variable is public; body operates on secret data.
declare void @llvm.protean.markpublic.i64(i64)

define i64 @loop_sum(i64* nocapture readonly %arr, i64 %n) {
entry:
  call void @llvm.protean.markpublic.i64(i64 %n)
  br label %loop
loop:
  %i   = phi i64 [ 0, %entry ], [ %i.next, %loop ]
  %acc = phi i64 [ 0, %entry ], [ %acc.next, %loop ]
  %ptr = getelementptr inbounds i64, i64* %arr, i64 %i
  %val = load i64, i64* %ptr
  %acc.next = add i64 %acc, %val
  %i.next   = add i64 %i, 1
  %done     = icmp eq i64 %i.next, %n
  br i1 %done, label %exit, label %loop
exit:
  ret i64 %acc
}