snippets-addin
==============

[![Travis-CI Build Status](https://api.travis-ci.org/sfr/RStudio-Addin-Snippets.svg?branch=master)](https://api.travis-ci.org/sfr/RStudio-Addin-Snippets.svg?branch=master)
[![Issue Count](https://codeclimate.com/github/sfr/RStudio-Addin-Snippets/badges/issue_count.svg)](https://codeclimate.com/github/sfr/RStudio-Addin-Snippets)
[![codecov](https://codecov.io/gh/sfr/RStudio-Addin-Snippets/branch/master/graph/badge.svg?ts=1)](https://codecov.io/gh/sfr/RStudio-Addin-Snippets)
[![CRAN version](http://www.r-pkg.org/badges/version/snippetsaddin)](https://cran.r-project.org/package=snippetsaddin)

RStudio add-in to add some code snippets, or help with code editing.

Currently it contains following functions:

* [Insert and reformat pipe](#insert-and-reformat-pipe)
* [Reverse slashes](#reverse-slashes)

Insert and reformat pipe
------------------------

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

Reverse slashes
---------------

This functionality is especially useful, when copying paths in Windows.

It will reverse all slashes either __in the selected block(s) of code__,
or if there is no selection (or only whitespace is selected), it will reverse
__all slashes in the clipboard__ and __paste it to the current cursor(s) position(s)__.
