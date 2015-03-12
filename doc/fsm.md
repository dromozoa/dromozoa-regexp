# FSM (Finite State Machine)

```
fsm = {
  "transition": [ transition* ],
  "start": [ state* ],
  "accept": [ state* ]
}

transiton
  = [ state, state, condition ]

state
  = NUMBER # positive integer

condition
  = character_class
  | 0 # epsilon
  | 1 # "^"
  | 2 # "$"

character_class
  = CHAR
  | -1 # any
  | bracket_expression
```
