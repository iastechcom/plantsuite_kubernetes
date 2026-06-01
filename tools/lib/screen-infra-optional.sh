#!/usr/bin/env bash
# Tela 3.5/4 — Infraestrutura Opcional (exibida somente quando só gateway é selecionado)
LAYOUT_NAME="3.5/4 Infra Opcional"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common/tui.sh
source "$SCRIPT_DIR/common/tui.sh"

# Descrições exibidas ao lado de cada componente opcional
_infra_opt_desc() {
    case "$1" in
        rabbitmq)     echo "mensagens entre serviços (gateway opera sem ele)" ;;
        vernemq)      echo "broker MQTT local (gateway pode usar broker externo)" ;;
        metrics-server) echo "métricas do cluster para HPA" ;;
        aspire)       echo "dashboard de observabilidade (traces/logs)" ;;
        *)            echo "" ;;
    esac
}

run_screen_infra_optional() {
    tui_check_compat

    local -a opts=("${GATEWAY_INFRA_OPTIONAL[@]}")
    local n=${#opts[@]}
    local -a sel=()
    local i
    for ((i=0; i<n; i++)); do sel[$i]=0; done   # todos desmarcados por padrão

    # ── Modo plain ────────────────────────────────────────────────────────────
    if [[ $TUI_PLAIN -eq 1 ]]; then
        echo ""
        echo "=== Infraestrutura Opcional (Gateway) ==="
        echo "Componentes não obrigatórios para o gateway."
        echo "Digite os números dos que deseja instalar, ou ENTER para pular todos."
        echo ""
        for ((i=0; i<n; i++)); do
            printf '  %d) [ ] %-16s %s\n' "$((i+1))" "${opts[$i]}" "$(_infra_opt_desc "${opts[$i]}")"
        done
        echo ""
        read -rp "Marcar (ex: 1,2), ENTER=nenhum, B=voltar, Q=sair: " input
        echo ""

        case "${input,,}" in
            q) [[ -n "${RESULT_FILE:-}" ]] && echo "__QUIT__" > "$RESULT_FILE" || echo "__QUIT__"; return ;;
            b) [[ -n "${RESULT_FILE:-}" ]] && echo "__BACK__" > "$RESULT_FILE" || echo "__BACK__"; return ;;
        esac

        if [[ -n "$input" ]]; then
            IFS=',' read -ra choices <<< "$input"
            local c
            for c in "${choices[@]}"; do
                c="${c// /}"
                if [[ "$c" =~ ^[0-9]+$ ]] && (( c >= 1 && c <= n )); then
                    sel[$((c-1))]=1
                fi
            done
        fi

        local skip_list=""
        for ((i=0; i<n; i++)); do
            [[ ${sel[$i]} -eq 0 ]] && skip_list="${skip_list:+$skip_list }${opts[$i]}"
        done

        [[ -n "${RESULT_FILE:-}" ]] && echo "$skip_list" > "$RESULT_FILE" || echo "$skip_list"
        return
    fi

    # ── Modo TUI ─────────────────────────────────────────────────────────────
    tui_init
    tui_init_colors

    local cursor=0 running=1 key=""
    input_flush

    while [[ $running -eq 1 ]]; do
        _tui_move_cursor 0 0
        draw_header

        local tbl_top=$((HEADER_HEIGHT + 1))
        local tbl_h=$((TUI_LINES - tbl_top - 4))
        [[ $tbl_h -lt 8 ]] && tbl_h=8
        draw_box "$tbl_top" 1 "$tbl_h" "$((TUI_COLS-2))" "Infraestrutura Opcional (Gateway)"

        at "$((tbl_top+1))" 2 "$(trunc "  Componentes opcionais para o gateway. SPACE para selecionar o que deseja instalar." $((TUI_COLS-4)))" "$C_DIM"

        for ((i=0; i<n; i++)); do
            local checkbox="[ ]"
            [[ ${sel[$i]} -eq 1 ]] && checkbox="[x]"
            local label=" $checkbox  ${opts[$i]}  $(_infra_opt_desc "${opts[$i]}")"
            local attr=""; [[ $i -eq $cursor ]] && attr="$C_SELECTED"
            tput cup "$((tbl_top+2+i))" 2 2>/dev/null || true
            clear_area "$((tbl_top+2+i))" 2 "$((TUI_COLS-4))"
            tput cup "$((tbl_top+2+i))" 2 2>/dev/null || true
            if [[ -n "$attr" ]]; then
                printf '%s%s%s' "$attr" "$(trunc "$label" $((TUI_COLS-4)))" "$C_RESET"
            else
                printf '%s' "$(trunc "$label" $((TUI_COLS-4)))"
            fi
        done

        local hint="  ↑↓ navegar   space marcar/desmarcar   enter confirmar   b voltar   q sair"
        tput cup "$((TUI_LINES - 1))" 0 2>/dev/null || true
        tput el 2>/dev/null || true
        colorize_hint "$(trunc "$hint" "$TUI_COLS")"

        _tui_move_cursor 0 0
        key=$(read_key) || continue
        case "$key" in
            RESIZE) tui_on_resize ;;
            UP)     cursor=$(( (cursor - 1 + n) % n )) ;;
            DOWN)   cursor=$(( (cursor + 1) % n )) ;;
            SPACE)  sel[$cursor]=$(( 1 - sel[$cursor] )) ;;
            ENTER)  running=0 ;;
            b)      running=0; key="BACK" ;;
            QUIT|ESC|q) running=0; key="QUIT" ;;
        esac
    done

    _tui_cleanup
    trap - EXIT INT TERM WINCH

    if [[ "$key" == "QUIT" ]]; then
        [[ -n "${RESULT_FILE:-}" ]] && echo "__QUIT__" > "$RESULT_FILE" || echo "__QUIT__"
        return
    fi
    if [[ "$key" == "BACK" ]]; then
        [[ -n "${RESULT_FILE:-}" ]] && echo "__BACK__" > "$RESULT_FILE" || echo "__BACK__"
        return
    fi

    local skip_list=""
    for ((i=0; i<n; i++)); do
        [[ ${sel[$i]} -eq 0 ]] && skip_list="${skip_list:+$skip_list }${opts[$i]}"
    done
    [[ -n "${RESULT_FILE:-}" ]] && echo "$skip_list" > "$RESULT_FILE" || echo "$skip_list"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run_screen_infra_optional
fi
