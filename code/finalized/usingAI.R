######### Using integrated AI tools in RStudio ########
#!!! NOTE: YOU NEED A COPILOT LICENCE TO USE THE COPILOT AI MODELS !!!#
## 1. Code completion
# turn on autocompletion in RStudio: Tools > Global Options > Code > Completion > Show code completions
# you can set when autocompletion is triggered (e.g., after 1 character, 2 characters, etc.)

## 2. GitHub Copilot or Posit Assistant in RStudio
# Posit Assistant is a new feature in RStudio that allows you to interact with AI models directly in the IDE.
# PA works with different models, incl. GitHub Copilot --> we can use our
# GitHub accounts to access the free version of Copilot.  
# Student Developer Pack should give you access to a paid version of Copilot for free.

# Posit Assistant is available for RStudio Desktop or Server 2026.04.0 and later
# --> it will not work on university computers!
# check your version of RStudio: Help > About RStudio
# Enable PA: Tools > Global Options > Assistant > Enable Posit Assistant

## 2. Chatting with Claude in RStudio 
# we need to install the ellmer package developed by Hadley Wickham:
install.packages("ellmer")
# pull the package:
library(ellmer)

# Claude is a paid model. 
#  --> You need to set up a payment method with Anthropic and use your API key.
# Then, configure your API key so that RStudio knows it:
Sys.setenv(ANTHROPIC_API_KEY = "Your key here")
file.edit(".Renviron")
    # R should now communicate with Anthropic and know you as a user

# We need to create a chat object:
claude <- chat_anthropic()
# And enter the chat:
live_console(claude)
# The >>> line in the console shows that you are in the chat console. 
# What you type after >>> into the console is your prompt.
# Typing Q will quit the chat (single > sign shows you are in console mode).

# Alternative method: no need to enter and exit chat mode, run from Source window
claude$chat("Your prompt")