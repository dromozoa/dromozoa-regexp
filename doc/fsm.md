# FSM (Finite State Machine)

## 遷移条件

遷移条件はゼロ幅遷移とEREの抽象構文木の文字で構成される。

```
condition
  = [ "epsilon" ]
  | [ "^" ]
  | [ "$" ]
  | [ "char", string ]
  | [ "\\", string ]
  | [ "." ]
  | bracket_expression

bracket_expression
  = [ "[", expression_term+ ] # matching list
  | [ "[^", expression_term+ ] # nonmatching list

expression_term
  = [ "[=", string ] # equivalence class
  | [ "[:", string ] # character class
  | [ "[-", end_range, end_range ]
  | end_range

end_range
  = [ "[.", string ] # collating symbol
  | [ "[char", string ]
```
