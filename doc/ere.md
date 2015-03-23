# ERE (Extended Regular Expression)

## EREの文法

expressionにanchoringとduplicationを含むため、SUSが定義する文法は判りづらく曖昧である。ECMAScriptの文法を踏襲し、assertion, atom, quantifierに分解して整理した。

```
DUP_COUNT
  = ("0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9")+

extended_reg_exp
  = ERE_branch ("|" ERE_branch)*

ERE_branch
  = ERE_expression+

ERE_expression
  = one_char_or_coll_elem_ERE_or_grouping ERE_dupl_symbol?
  | "^"
  | "$"

one_char_or_coll_elem_ERE_or_grouping
  = not ("^" | "." | "[" | "$" | "(" | ")" | "|" | "*" | "+" | "?" | "{" | "\\")
  | "\\" ("^" | "." | "[" | "$" | "(" | ")" | "|" | "*" | "+" | "?" | "{" | "\\")
  | "."
  | bracket_expression
  | "(" extended_reg_exp ")"

ERE_dupl_symbol
  = "*"
  | "+"
  | "?"
  | "{" DUP_COUNT "}"
  | "{" DUP_COUNT "," "}"
  | "{" DUP_COUNT "," DUP_COUNT"}"
```

## bracket expressionの文法

collating symbol, equivalence class, character classを一文字以上の貪欲でない一致で表現している。詳細な定義は「ロケール」節で行う。

```
bracket_expression
  = "[" "^"? expression_term+ "-"? "]"

expression_term
  = "[=" .+? "=]" # equivalence class
  | "[:" .+? ":]" # character class
  | end_range "--"
  | end_range "-" end_range
  | end_range

end_range
  = "[." .+? ".]" # collating symbol
  | not ("^" | "-" | "]")
```

## ロケール

POSIXロケールだけを対象とすることで照合順序の問題を単純化する。

### collating symbol

US-ASCIIで有効な128文字について、その文字自体であるような照合要素が定義される。これらの照合要素だけが有効なcollating symbolである。

### equivalence class

有効なequivalence classは存在しない。

### character class

12個のcharacter classが存在する。

```
class_name
  = "alnum"
  | "alpha"
  | "blank"
  | "cntrl"
  | "digit"
  | "graph"
  | "lower"
  | "print"
  | "punct"
  | "space"
  | "upper"
  | "xdigit"
```

## 抽象構文木

```
extended_reg_exp
  = [ "|", ERE_branch+ ]

ERE_branch
  = [ "concat", ERE_expression+ ]

ERE_expression
  = one_char_or_coll_elem_ERE_or_grouping
  | ERE_dupl_symbol
  | [ "^" ]
  | [ "$" ]

one_char_or_coll_elem_ERE_or_grouping
  = [ "char", string ]
  | [ "\\", string ]
  | [ "." ]
  | bracket_expression
  | extended_reg_exp

ERE_dupl_symbol
  = [ "+", one_char_or_coll_elem_ERE_or_grouping ]
  | [ "*", one_char_or_coll_elem_ERE_or_grouping ]
  | [ "?", one_char_or_coll_elem_ERE_or_grouping ]
  | [ "{m", one_char_or_coll_elem_ERE_or_grouping, m ]
  | [ "{m,", one_char_or_coll_elem_ERE_or_grouping, m ]
  | [ "{m,n", one_char_or_coll_elem_ERE_or_grouping, m, n ]

bracket_expression
  = [ "[", expression_term+ ]
  | [ "[^", expression_term+ ]

expression_term
  = [ "[=", string ] # equivalence class
  | [ "[:", string ] # character class
  | [ "[-", end_range, end_range ]
  | end_range

end_range
  = [ "[.", string ] # collating symbol
  | [ "[char", string ]
```

## 参考文献

* [Boost 1.57.0 | POSIX Extended Regular Expression Syntax](http://www.boost.org/doc/libs/1_57_0/libs/regex/doc/html/boost_regex/syntax/basic_extended.html)
* [ECMAScript 5.1 | 15.10 RegExp (Regular Expression) Objects](http://www.ecma-international.org/ecma-262/5.1/#sec-15.10)
* [SUSv4 | 7.2 POSIX Locale](http://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap07.html#tag_07_02)
* [SUSv4 | 9.4 Extended Regular Expressions](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_04)
