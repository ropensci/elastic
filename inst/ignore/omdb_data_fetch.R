get_omdb <- function(x, ...) {
  url <- URLencode(sprintf('http://www.omdbapi.com/?t=%s&r=json', x))
  res <- httr::GET(url, ...)
  httr::stop_for_status(res)
  jsonlite::fromJSON(httr::content(res, "text", encoding = "UTF-8"))
}

movies <- c("iron man", 'iron man 2', 'frozen', 'ghostbusters', 'bourne identity',
            'Game of Thrones', 'The Hunger Games', 'Guardians of the Galaxy', 
            'The Hunger Games: Catching Fire', 'The Imitation Game', 
            'The Great Gatsby', 'Sherlock Holmes: A Game of Shadows',
            'American Gangster', 'Gangs of New York', 'The Hunger Games: Mockingjay - Part 1',
            'The Ninth Gate', 'Galaxy Quest', 'Spy Game', 'Battlestar Galactica', 'Gamer', 
            'The Constant Gardener', 'The Life of David Gale', 'Patriot Games', 'Funny Games',
            'Garfield', 'The Gambler', 'Battlestar Galactica', 'Gangs of Wasseypur', 'Funny Games', 
            'The Game Plan', 'The Crying Game', 'Spy Kids 3-D: Game Over', 'Fair Game', 
            'Inspector Gadget','He Got Game', 'Gridiron Gang', 
            'Midnight in the Garden of Good and Evil', 'Reindeer Games', 'Gallipoli', 
            'The Dinner Game', 'The Secret Garden', 'Garfield 2', 'For Love of the Game', 
            'The Greatest Game Ever Played', 'The World According to Garp', 
            'Asterix at the Olympic Games', 'The Rules of the Game', 'Big Game', 'Big Game', 
            'The Great Gatsby', 'Gambit', 'Game Change', 'Gaslight', 
            'Battlestar Galactica: The Plan', 'Anne of Green Gables', 
            'Elevator to the Gallows', 'Assassination Games', 'Bring Me the Head of Alfredo Garcia', 
            'Pat Garrett & Billy the Kid', 'Battlestar Galactica: Blood & Chrome', 'The Gallows', 
            'Battlestar Galactica: Blood & Chrome', 'When the Game Stands Tall')
            movies <- c(
            'Game of Death', 'Inspector Gadget', 'Gabriel', 'Koi... Mil Gaya', 'Game of Death', 
            'Garth Marenghis Darkplace', 'Gangster No. 1', 'Video Game High School', 
            'Fireflies in the Garden', 'Gargoyles', 'The Gate', 'Battlestar Galactica', 
            'Fair Game', 'Cats & Dogs: The Revenge of Kitty Galore', 
            'The Angry Video Game Nerd', 'Hunting and Gathering', 
            'Gangsters Paradise: Jerusalema', 'Beyond the Gates', 'Heavens Gate', 'Galavant',
            'Gavin & Stacey', 'GasLand', 'Over the Garden Wall', 'I Am a Fugitive from a Chain Gang', 
            'Balls Out: Gary the Tennis Coach', 'Garam Masala', 'Forbidden Games', 
            'Surviving the Game', 'Battlestar Galactica: The Resistance', 'The Garden of Words',
            'Grey Gardens', 'The Hitch Hikers Guide to the Galaxy', 'The Hungover Games', 
            'Gainsbourg: A Heroic Life', 'Elmer Gantry', 'Gangaajal', 'Another Gay Movie', 
            'Garfield and Friends', 'Grey Gardens', 'Real Gangsters', 
            'The Most Dangerous Game', 'Babylon 5: The Gathering', 'Johnny Gaddaar', 'The Gates',
            'The Gathering', 'Asterix the Gaul', 'Flying Swords of Dragon Gate', 'Gamers', 
            'Flying Swords of Dragon Gate', 'Battlestar Galactica')

moviedat <- lapply(movies, get_omdb)
moviedat2 <- lapply(movies, get_omdb)
library(dplyr)
library(data.table)
df2 <- setDF(rbindlist(moviedat2, use.names = TRUE, fill = TRUE))
dfall <- bind_rows(tbl_df(df), tbl_df(df2))



for (i in seq_along(data_chks)) {
  setTxtProgressBar(pb, i)
  make_bulk(x[data_chks[[i]], ], index, type, id_chks[[i]], es_ids)
}
