# 1. Version
R.version.string                # native pipe |> needs R 4.1 or newer
packageVersion("tidyr")         # separate_wider_delim() needs tidyr 1.3.0 or newer

# 2. Permissions (0 = can write, -1 = cannot)
.libPaths()                     # where packages get installed
file.access(.libPaths()[1], 2)  # can you install packages there?
getwd()                         # the folder R is working in
file.access(getwd(), 2)         # can you save files there?

# 3. Network
nrow(available.packages())      # can R reach CRAN? (thousands = yes)
readLines("https://raw.githubusercontent.com/gabors-data-analysis/da-coding-rstats/main/lecture03-tibbles/data/games.csv", n = 2)
readLines("https://osf.io/download/p6tyr/", n = 2)