# snippets-addin

[![Travis-CI Build Status](https://api.travis-ci.org/sfr/RStudio-Addin-Snippets.svg?branch=master)](https://api.travis-ci.org/sfr/RStudio-Addin-Snippets.svg?branch=master)
[![Issue Count](https://codeclimate.com/github/sfr/RStudio-Addin-Snippets/badges/issue_count.svg)](https://codeclimate.com/github/sfr/RStudio-Addin-Snippets)
[![codecov](https://codecov.io/gh/sfr/RStudio-Addin-Snippets/branch/master/graph/badge.svg?ts=7)](https://codecov.io/gh/sfr/RStudio-Addin-Snippets)
[![CRAN version](http://www.r-pkg.org/badges/version/snippetsaddin)](https://cran.r-project.org/package=snippetsaddin)

RStudio add-in to add some code snippets, or help with code editing.
It is aimed to be used on Windows.

Currently it contains following functions:

* [Insert and reformat pipe](#insert-and-reformat-pipe)
* [Reverse slashes](#reverse-slashes)
* [Copy data to Clipboard](#copy-data-to-clipboard)

## Insert and reformat pipe

This functionality inserts pipes at the current position(s) of the cursor(s)
or replaces all selections. It reformats pipe(s) surroundings to achieve
following format:

```{r}
sub <- data %>%
    select(column.1, column.2) %>%
        filter(column.1 > x) %>%
            group_by(column.1) %>%
                summarise(n=n_distinct(column.2)) %>%
                    ungroup
```

* exactly one space before %>%
* line cannot start with %>% (unless it is first line of the file).
  * It will find last non-empty line before the cursor position.
* new line after %>%
* next line will be indented as the current line is + N spaces;
  * where N is dependent on the RStudio settings
* then it's followed by the next word, or it is the end of the line.

## Reverse slashes

This functionality is especially useful, when copying paths in Windows.

It will reverse all slashes either __in the selected block(s) of code__,
or if there is no selection (or only whitespace is selected), it will reverse
__all slashes in the clipboard__ and __paste it to the current cursor(s) position(s)__.


## Copy data to clipboard

At the moment this is Windows only function.

Function will copy the content of the variable under the cursor into
the clipboard. It will be represented as a __tab separated value__ for an easy
paste to MS Excel.

At the moment following data structures are supported:

* [vectors](#vectors)
* [matrices](#matrices)
* [data frames](#data-frames)
* [1D and 2D arrays](#arrays)

### Vectors

Vectors are represented in a horizontal fashion. If they are named then first
row will contain names and second values. In they are unnamed then only one row
with values is copied into the clipboard.

### Matrices

Value copied to clipboard will either have $M\times N$ or $(M+1)\times N$,
$M\times (N+1)$ or $(M+1)\times (N+1)$ cells, where $M$ and $N$ are matrix
dimensions. If matrix has specified columns names and/or rows names than they
will be displayed in the first column and row.

In the case that both columns names and rows names are specified, the content of
the top left cell will constructed from dimension names, if they exist; in the
following format: Row names dimension name, backslash, column names dimension
name. Examples below shows all cases. If dimensions are not named then variable
name will be used.

```{r}
mat.1 <- matrix(1:9, nrow=3, dimnames=list(rows=letters[1:3], columns=letters[24:26]))
```

| rows\\columns | x | y | z | 
|---------------|---|---|---| 
| a             | 1 | 4 | 7 | 
| b             | 2 | 5 | 8 | 
| c             | 3 | 6 | 9 | 

```{r}
mat.2 <- matrix(1:9, nrow=3, dimnames=list(letters[1:3], columns=letters[24:26]))
```

| \\columns | x | y | z | 
|-----------|---|---|---| 
| a         | 1 | 4 | 7 | 
| b         | 2 | 5 | 8 | 
| c         | 3 | 6 | 9 | 

```{r}
mat.3 <- matrix(1:9, nrow=3, dimnames=list(rows=letters[1:3], letters[24:26]))
```

| rows\\ | x | y | z | 
|--------|---|---|---| 
| a      | 1 | 4 | 7 | 
| b      | 2 | 5 | 8 | 
| c      | 3 | 6 | 9 | 

```{r}
mat.4 <- matrix(1:9, nrow=3, dimnames=list(letters[1:3], letters[24:26]))
```

| mat.4 | x | y | z | 
|-------|---|---|---| 
| a     | 1 | 4 | 7 | 
| b     | 2 | 5 | 8 | 
| c     | 3 | 6 | 9 | 

### Data frames

Data frames act as [matrices](#matrices).

### Arrays

1D arrays act as [vectors](#vectors).

2D arrays act as [matrices](#matrices).

3+D arrays - to be implemented.

![](https://reposs.herokuapp.com/?path=sfr/RStudio-Addin-Snippets)
[![Pending Pull-Requests](http://githubbadges.herokuapp.com/sfr/RStudio-Addin-Snippets/pulls.svg)](https://github.com/sfr/RStudio-Addin-Snippets/pulls)
