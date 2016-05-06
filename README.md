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
* [arrays](#arrays)

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

#### 1D arrays
1D arrays act as [vectors](#vectors).

#### 2D arrays
2D arrays act as [matrices](#matrices).

#### 3+D arrays
3+D arrays will be flatten into a [matrix](#matrices). Matrix will have $N+1$
columns where $N$ is a number of dimensions and $M$ or $M+1$ rows, where $M$ is
a product of array dimensions. E.g. if array has following dimensions
```r dim=c(2, 4, 2)```, then the output table will have $N=3+1=4$ columns and
$M=2*4*2=16$ rows. If array dimensions are named then header row will be added.
First $N$ columns will be take names from dimensions names and the last column
will be named after variable. Missing names will stay empty.

See examples below.

##### Example 1

3D array with defined dimension names. One of the dimension names is missing.
```{r}
(arr.3d <- array(1:24, dim=c(3, 4, 2), dimnames=list(x=c('a', 'b', 'c'), c('k', 'l', 'm', 'n'), z=c('x', 'y'))))
```

Print out:
```
, , z = x

   
x   k l m  n
  a 1 4 7 10
  b 2 5 8 11
  c 3 6 9 12

, , z = y

   
x    k  l  m  n
  a 13 16 19 22
  b 14 17 20 23
  c 15 18 21 24
```

In clipboard:
| x |   | z | arr.3d |
|---|---|---|--------|
| a | k | x |      1 |
| b | k | x |      2 |
| c | k | x |      3 |
| a | l | x |      4 |
| b | l | x |      5 |
| c | l | x |      6 |
| a | m | x |      7 |
| b | m | x |      8 |
| c | m | x |      9 |
| a | n | x |     10 |
| b | n | x |     11 |
| c | n | x |     12 |
| a | k | y |     13 |
| b | k | y |     14 |
| c | k | y |     15 |
| a | l | y |     16 |
| b | l | y |     17 |
| c | l | y |     18 |
| a | m | y |     19 |
| b | m | y |     20 |
| c | m | y |     21 |
| a | n | y |     22 |
| b | n | y |     23 |
| c | n | y |     24 |

##### Example 2

3D array without named dimensions.
```{r}
(arr.3d <- array(1:24, dim=c(3, 4, 2), dimnames=list(c('a', 'b', 'c'), c('k', 'l', 'm', 'n'), c('x', 'y'))))
```

Print out:
```
, , x

  k l m  n
a 1 4 7 10
b 2 5 8 11
c 3 6 9 12

, , y

   k  l  m  n
a 13 16 19 22
b 14 17 20 23
c 15 18 21 24
```

In clipboard:
| a | k | x |  1 |
| b | k | x |  2 |
| c | k | x |  3 |
| a | l | x |  4 |
| b | l | x |  5 |
| c | l | x |  6 |
| a | m | x |  7 |
| b | m | x |  8 |
| c | m | x |  9 |
| a | n | x | 10 |
| b | n | x | 11 |
| c | n | x | 12 |
| a | k | y | 13 |
| b | k | y | 14 |
| c | k | y | 15 |
| a | l | y | 16 |
| b | l | y | 17 |
| c | l | y | 18 |
| a | m | y | 19 |
| b | m | y | 20 |
| c | m | y | 21 |
| a | n | y | 22 |
| b | n | y | 23 |
| c | n | y | 24 |


##### Example 3

Bare 3D array.
```{r}
(arr.3d <- array(1:24, dim=c(3, 4, 2)))
```

Print out:
```
, , 1

     [,1] [,2] [,3] [,4]
[1,]    1    4    7   10
[2,]    2    5    8   11
[3,]    3    6    9   12

, , 2

     [,1] [,2] [,3] [,4]
[1,]   13   16   19   22
[2,]   14   17   20   23
[3,]   15   18   21   24
```

In clipboard:
| A | A | A |  1 |
| B | A | A |  2 |
| C | A | A |  3 |
| A | B | A |  4 |
| B | B | A |  5 |
| C | B | A |  6 |
| A | C | A |  7 |
| B | C | A |  8 |
| C | C | A |  9 |
| A | D | A | 10 |
| B | D | A | 11 |
| C | D | A | 12 |
| A | A | B | 13 |
| B | A | B | 14 |
| C | A | B | 15 |
| A | B | B | 16 |
| B | B | B | 17 |
| C | B | B | 18 |
| A | C | B | 19 |
| B | C | B | 20 |
| C | C | B | 21 |
| A | D | B | 22 |
| B | D | B | 23 |
| C | D | B | 24 |

# Collection of badges

![Repository size](https://reposs.herokuapp.com/?path=sfr/RStudio-Addin-Snippets)
[![Pending Pull-Requests](http://githubbadges.herokuapp.com/sfr/RStudio-Addin-Snippets/pulls.svg)](https://github.com/sfr/RStudio-Addin-Snippets/pulls)
![downloads](https://img.shields.io/github/downloads/sfr/RStudio-Addin-Snippets/total.svg?maxAge=2592000)
[![release version](https://img.shields.io/github/release/sfr/RStudio-Addin-Snippets.svg?maxAge=2592000)](https://github.com/sfr/RStudio-Addin-Snippets/releases)
[![license](https://img.shields.io/badge/license-GPLv2-green.svg)](https://github.com/sfr/RStudio-Addin-Snippets/blob/master/LICENSE)
