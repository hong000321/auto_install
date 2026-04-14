#!/bin/bash
# Name: auto_install.sh
# Purpose: 시스템 도구 자동 설치 및 환경 설정 (중복 실행 방지)
# Author: 홍대오

# 성공 기록 파일 경로
SUCCESS_LOG="$HOME/.custom_install_success"

check_install() {
    if [ $# -lt 2 ]; then
        echo "Usage: check_install <command_or_id> <execution_script...>"
        return 1
    fi

    local CMD_NAME=$1
    shift
    local FULL_COMMAND=$@

    # 1. 시스템에 명령어가 이미 있는지 확인
    if command -v "$CMD_NAME" >/dev/null 2>&1; then
        echo "[$CMD_NAME] 시스템에 이미 존재합니다. (Skip)"
        return 0
    fi

    # 2. 성공 기록 파일에 해당 식별자가 있는지 확인
    if [ -f "$SUCCESS_LOG" ] && grep -qx "$CMD_NAME" "$SUCCESS_LOG"; then
        echo "[$CMD_NAME] 설치 기록이 확인되었습니다. (Skip)"
        return 0
    fi

    # 3. 위 두 조건에 모두 해당하지 않으면 명령 실행
    echo "[$CMD_NAME] 설치를 시작합니다..."
    
    # eval을 통해 전달받은 명령어를 실행하고, 성공(exit code 0)하면 기록함
    if eval "$FULL_COMMAND"; then
        # [핵심] 성공 시에만 기록 파일에 추가
        echo "$CMD_NAME" >> "$SUCCESS_LOG"
        echo "[$CMD_NAME] 설치 성공 및 기록 완료!"
        return 0
    else
        echo "[$CMD_NAME] 설치 실패. 명령어를 확인하세요."
        return 1
    fi
}

install_gh_release() {
    if [ $# -lt 2 ]; then
        echo "Usage: install_gh_release <user/repo> <keyword1> [keyword2] ..."
        echo "Ex: https://github.com/Eugeny/tabby/releases/download/v1.0.230/tabby-1.0.230-linux-x64.deb \
          ->  install_gh_release Eugeny/tabby deb linux-x64"
        return 1
    fi

    local REPO=$1
    shift
    local KEYWORDS=$@
    
    echo "[$REPO] 최신 릴리스 탐색 중..."

    # 1. API 호출 및 모든 키워드를 포함하는 URL 필터링
    local SEARCH_CMD="grep 'browser_download_url'"
    for kw in $KEYWORDS; do
        SEARCH_CMD+=" | grep -i '$kw'"
    done

    local LATEST_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
        | eval "$SEARCH_CMD" \
        | cut -d : -f 2,3 \
        | tr -d \" | xargs)

    # URL 확인 실패 시 예외 처리
    if [ -z "$LATEST_URL" ]; then
        echo "에러: 해당 키워드($KEYWORDS)와 일치하는 다운로드 링크를 찾을 수 없습니다."
        return 1
    fi

    local FILENAME=$(basename "$LATEST_URL")
    local EXT="${FILENAME##*.}"

    echo "1. 최신 버전 확인: $FILENAME"
    
    # 2. 다운로드
    echo "2. 다운로드 시작..."
    wget -q --show-progress "$LATEST_URL" -O "/tmp/$FILENAME"

    # 3. 확장자에 따른 설치 분기
    echo "3. 설치 시작 ($EXT 형식)..."
    case "$EXT" in
        deb)
            sudo dpkg -i "/tmp/$FILENAME"
            sudo apt-get install -f -y
            ;;
        rpm)
            sudo rpm -ivh "/tmp/$FILENAME"
            ;;
        gz|zip)
            echo "압축 파일입니다. /tmp/$FILENAME 에 다운로드되었습니다. 수동 설치가 필요합니다."
            return 0
            ;;
        *)
            echo "지원하지 않는 확장자입니다: $EXT"
            return 1
            ;;
    esac

    # 4. 정리
    rm "/tmp/$FILENAME"
    echo "--------------------------------------------------"
    echo "[$REPO] 설치가 완료되었습니다!"
}




check_install "htop" "sudo apt update && sudo apt install -y htop"

check_install "tabby" "install_gh_release Eugeny/tabby deb x64"

check_install "python3" "
	sudo apt install -y python3 && \
	sudo apt install -y python3-pip
"
check_install "python" "sudo ln -s $(which python3) /usr/bin/python"

check_install "code" "sudo snap install --classic code"

check_install "zellij" "install_gh_release zellij-org/zellij tar.gz x86_64-unknown-linux-musl"

check_install "fd" "sudo apt install fd-find && sudo mv /usr/bin/fdfind /usr/bin/fd"

check_install "rg" "sudo apt install ripgrep"

alias hdo_test="echo test success!!!"
exec bash
