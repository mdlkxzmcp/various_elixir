# What Are Types?

## the Keyword type that is implemented as a list of tuples
options = [ {:width, 72}, {:style, "light"}, {:style, "print"} ]

## list functions work on this
List.last options

## but it can also be worked on as if it was a dictionary
Keyword.get_values options, :style
