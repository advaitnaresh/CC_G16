

declare void @printi(i32)

define i32 @main() {
entry:
  %a = alloca i32
  store i32 0, i32* %a
  %a1 = load i32, i32* %a
  call void @printi(i32 %a1)
  ret i32 0
}