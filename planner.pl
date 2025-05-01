% Main Predicate
plan_transport( Initial_State, 
                Goal_State, 
                Set_of_Invalid_Combinations, 
                Drivers, 
                Max_Plan_Length, 
                SortedPlan) :-

    nonvar(Set_of_Invalid_Combinations),
    nonvar(Drivers),
    integer(Max_Plan_Length),
    Max_Plan_Length >= 0,

    order_state(Initial_State, SortedInitial), order_state(Goal_State, SortedGoal),

    transport(  SortedInitial, 
                SortedGoal, 
                Set_of_Invalid_Combinations, 
                Drivers, 
                Max_Plan_Length, 
                left, 
                [], 
                RevPlan),

    reverse(RevPlan, Plan),
    sortsteps(Plan, SortedPlan).

% Base case.
transport(State1, State2, _, _, _, _, Plan, Plan):-
   order_state(State1, Ordered), order_state(State2, Ordered).

% Recursive step.
transport(  CurrentState, 
            Goal_State, 
            Set_of_Invalid_Combinations, 
            Drivers, 
            MovesLeft, 
            CurrentSide, 
            PlanSoFar, 
            Plan) :-

    MovesLeft > 0,

    select_move(  CurrentState, 
                  CurrentSide,
                  Drivers,
                  Move, 
                  NextState,
                  NextSide),
                  \+ invalid_state(NextState, Set_of_Invalid_Combinations),

    transport(  NextState, 
                Goal_State, 
                Set_of_Invalid_Combinations,
                Drivers, 
                MovesLeft - 1, 
                NextSide, 
                [Move | PlanSoFar], 
                Plan).

% Generate a valid move
select_move(  [Left, Right], 
              left, Drivers, 
              [go_right | Objects], 
              [SortedLeft, SortedRight], 
              right) :-

    select_objects(Left, Drivers, Objects),
    move_objects(Objects, Left, NewLeft),
    append(Objects, Right, NewRight),
    sort(NewLeft, SortedLeft), sort(NewRight, SortedRight).

select_move(  [Left, Right],
              right, 
              Drivers, 
              [go_left | Objects], 
              [SortedLeft, SortedRight], 
              left) :-

    select_objects(Right, Drivers, Objects),
    move_objects(Objects, Right, NewRight),
    append(Objects, Left, NewLeft),
    sort(NewLeft, SortedLeft), sort(NewRight, SortedRight).

% Select the driver and optionally one other object
select_objects(Side, Drivers, [Driver]) :-
    member(Driver, Drivers),
    member(Driver, Side).

select_objects(Side, Drivers, [Driver, Other]) :-
    member(Driver, Drivers),
    member(Driver, Side),
    member(Other, Side),
    Driver \= Other.

% Move the given objects from one side to another
move_objects([], From, From).
move_objects([Obj|Objs], From, NewFrom) :-
    select(Obj, From, TempFrom),
    move_objects(Objs, TempFrom, NewFrom).

% Check for invalid combinations where the driver is not present.
invalid_state([Left, Right], Set_of_Invalid_Combinations) :-
    ( \+ member(farmer, Left), has_invalid_combo(Left, Set_of_Invalid_Combinations)
    ; \+ member(farmer, Right), has_invalid_combo(Right, Set_of_Invalid_Combinations)
    ).

% Predicate for invalid combination.
has_invalid_combo(Side, Set_of_Invalid_Combinations) :-
    member(Invalid, Set_of_Invalid_Combinations),
    subset(Invalid, Side).

order_state([Left, Right], [SortedLeft, SortedRight]) :-
    sort(Left, SortedLeft), sort(Right, SortedRight).

% Subset
subset([], _).
subset([X|Xs], Set) :-
    member(X, Set),
    subset(Xs, Set).

% Canonical sorting
sortsteps([], []).
sortsteps([X|Y], [T|Z]) :- sortstep(X, T), sortsteps(Y, Z).

sortstep([], []).
sortstep([M|T], [M|ST]) :- sort(T, ST).
