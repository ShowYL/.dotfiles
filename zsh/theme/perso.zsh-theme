# --- Zsh Prompt Configuration ---
# Load Zsh's version control system and set it to run before each prompt
autoload -Uz vcs_info
precmd() { vcs_info }
preexec() { echo "" }  # Adds a blank line before output for readability

# Git branch format
zstyle ':vcs_info:git:*' formats ' %b%f'
setopt PROMPT_SUBST

# Shorten current path if too long
shorten_path() {
  local path="${PWD/#$HOME/~}"  # Replace $HOME with ~
  local path_length=${#path}
  if (( path_length > 15 )); then
    echo "...${path: -10}"
  else
    echo "$path"
  fi
}

# Prompt colors (TrueColor RGB and 256-color fallback)
CUSTOM_BLUE='%F{#707BFA}'
CUSTOM_GRAY='%F{#948D9B}'
RESET_PROMPT='%f'

HOSTNAME=$(hostname)
length=${#HOSTNAME}

# Prompt string

if (( length < 15 )); then
  PROMPT="%(?..%F{red}Exit %?%f
)
  ┌─[%B${CUSTOM_BLUE}${USER} ${RESET_PROMPT} ${CUSTOM_BLUE}\$(shorten_path)${RESET_PROMPT}%b] ${CUSTOM_GRAY}\${vcs_info_msg_0_}${RESET_PROMPT}
  └> "
else
  PROMPT="%(?..%F{red}Exit %?%f
)
  ┌─[${CUSTOM_BLUE}${USER} ${RESET_PROMPT} ${CUSTOM_BLUE}%~${RESET_PROMPT}]  ${CUSTOM_GRAY}\${vcs_info_msg_0_}${RESET_PROMPT}
  └> "
fi

# --- ANSI Color Definitions ---
# Use $'' quoting to allow proper interpretation in Zsh
# Reset
RESET_COLOR=$'\033[0m'

# Regular Colors
Black=$'\033[0;30m'  Red=$'\033[0;31m'     Green=$'\033[0;32m'  Yellow=$'\033[0;33m'
Blue=$'\033[0;34m'   Purple=$'\033[0;35m'  Cyan=$'\033[0;36m'   White=$'\033[0;37m'

# Bold
BBlack=$'\033[1;30m' BRed=$'\033[1;31m'    BGreen=$'\033[1;32m' BYellow=$'\033[1;33m'
BBlue=$'\033[1;34m'  BPurple=$'\033[1;35m' BCyan=$'\033[1;36m'  BWhite=$'\033[1;37m'

# High Intensity RGB
CUSTOM_BLUE_ANSI=$'\033[38;2;112;123;250m'  # RGB for #707BFA

# --- Welcome Message on New Terminal ---
host=$(hostname)
ip=$(hostname -I 2>/dev/null | awk '{print $1}')
ip=${ip:-"Unavailable"}
uptime=$(uptime -p 2>/dev/null | sed 's/up //')

# Battery status
battery=""
if [[ -d /sys/class/power_supply/BAT0 ]]; then
  battery=$(acpi -b 2>/dev/null | grep -Eo '[0-9]+%')
fi
battery_status=${battery:-Sector}

# Terminal width and centering
terminal_width=$(tput cols 2>/dev/null || echo 80)
padding_spaces=$(( (terminal_width - 70) / 2 ))
pad=$(printf '%*s' "$padding_spaces")

# Prepare ascii art and info as separate variables
echo ""
echo ""
ascii_art=$(cat <<'EOF'
  ██╗  ██╗ ██████╗ ███╗   ███╗███████╗        
  ██║  ██║██╔═══██╗████╗ ████║██╔════╝        
  ███████║██║   ██║██╔████╔██║█████╗          
  ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝          
  ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗        
  ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝        
EOF
)

info_text=$(cat <<EOF
  ${CUSTOM_BLUE_ANSI}${USER}${White} on ${host} ${RESET_COLOR}
  IP      : ${CUSTOM_BLUE_ANSI}${ip}${RESET_COLOR}
  Uptime  : ${CUSTOM_BLUE_ANSI}${uptime}${RESET_COLOR}
  Battery : ${CUSTOM_BLUE_ANSI}${battery_status}${RESET_COLOR}
EOF
)

# Use paste to print side-by-side
paste <(echo "$ascii_art" | lolcat -f) <(echo "$info_text") | sed "s/^/${pad}/"

# Greeting
printf "\n  Welcome back ${BGreen}${USER}${RESET_COLOR}\n"
