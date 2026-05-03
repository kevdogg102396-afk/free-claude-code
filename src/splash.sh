#!/bin/bash
# Nemo Code splash screen by ClawdWorks

CYAN='\033[0;36m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "${BLUE}     .    *       .          *        .       *      .${RESET}"
echo -e "${BLUE}  *          .         *           .             *    ${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}   CLAWD WORKS${RESET}"
echo -e "${CYAN}${BOLD}              n e m o - c o d e${RESET}"
echo ""
echo -e "${DIM}      All the security. All the reliability. ALL the ease.${RESET}"
echo ""
echo -e "${BLUE}     .    *       .          *        .       *      .${RESET}"
echo ""
echo -e "  ${WHITE}Model:${RESET}   ${CYAN}${NEMO_MODEL:-moonshotai/kimi-k2.6}${RESET}"
echo -e "  ${WHITE}Tokens:${RESET}  ${CYAN}${NEMO_MAX_TOKENS:-16384}${RESET}"
echo -e "  ${WHITE}Mode:${RESET}    ${CYAN}Sandboxed Docker${RESET}"
echo ""
echo -e "${DIM}  /model switches between Kimi K2.6, Qwen 3.5, and MiniMax M2.7${RESET}"
echo ""
