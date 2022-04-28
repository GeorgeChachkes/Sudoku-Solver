% libraries to include 
:- use_module(library(between)).
:- use_module(library(lists)).
:- use_module(library(clpfd)).

split(0, L, F, B):-
    F = [], 
    B = L.

split(N, [H|T], [H|TF], B):-
    (   N > 0 ->  N0 is N-1,
    split(N0, T, TF, B)
    ).

chop(N, L, [H|T]) :-
    length(L, Len),
    Len > N ->  
    	split(N, L, F, B),
    	H = F,
    	chop(N, B, T)  
    ;   H = L, T = [].
 
% Checks if a list contains unique elements 
unique_list(L):-
    findall(X, (member(X,L), X>0), L1),
    length(L1, N1),
    sort(L1, L2),	% Finds the unique elements of L
    length(L2, N1). % If the list of unique elements 
					% has the same length as L, then
					% the list has to be unique.

% checks if the rows are consistent 
consistent_rows([]). 
consistent_rows([H|T]):-
	unique_list(H),
    consistent_rows(T). 

% Gets the transpose
% Make sure that the rows of the transposed matrix,
% which are the columns of the original matrix
consistent_cols(G):-
    transpose(G, GT), 
    consistent_rows(GT). 

consistent_grid2([]).
consistent_grid2([A|T]):-
    append(A, L),  % Convert the grid into a list of elements 
    unique_list(L), % Check if the list of elements is unique 
    consistent_grid2(T). % move to next grid 
    
consistent_grid1(_, []).
consistent_grid1(K,[A|T]):-
    transpose(A, AT), 
    chop(K, AT, L1),  		% transpose and chop each K region into K regions, such that a grid 
    				  		% will have a size of KxK now 
    consistent_grid2(L1),   % check grid 
    consistent_grid1(K, T). % move to next region.
    
% Checks if the grids of a suduko is consistent  
consitent_grid(G):-
    length(G, M), 
    K is integer(sqrt(M)), % calculate grid size 
    chop(K, G, G0),        % separate the grid into K regions
    consistent_grid1(K, G0).
   
consistent(G):-
    consistent_rows(G), % check rows
    consistent_cols(G), % check columns
    consitent_grid(G).  % check grid 

fill(Rs0, Rs, K):- % Rs is unsolved sudoku, Rs is the solved grid, K is the size of the grid
    % we go through each row 
    % we replace each zero with a variable X
    % such that X is between 1, K
    (   select(R0, Rs0, R, Rs1), select(0, R0, X, R) ->  
    between(1, K, X),
    % After the replacement, we check if the resulting matrix is valid 
    consistent(Rs1),
    fill(Rs1, Rs, K)
    ;   Rs = Rs0).

sudoku0(G0, G):-
    length(G0, K),  % get the size of the grid 
    fill(G0, G, K). % fill the grid with numbers between 1 and K
    
	
