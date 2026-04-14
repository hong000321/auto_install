# 🚀 Auto Install

자동 환경 설정 스크립트입니다. 이미 설치된 항목은 알아서 건너뜁니다.

## ✅ 사용 방법
1. **권한 부여**: `chmod +x auto_install.sh`
2. **실행**: `./auto_install.sh`
3. **설정 적용**: `source ~/.bashrc` (또는 터미널 재시작)(필요 시 실행)

## 🛠 주요 기능
- **중복 방지**: 동일한 도구를 두 번 설치하지 않음
- **기록 확인**: `~/.custom_install_success` 파일에 성공 내역 저장
- **명령어 연결**: `python3`를 `python`으로 자동 연결
- **터미널 설정**: Git 브랜치 및 사용자 이름 표시 설정

## 🛠 함수 사용법
새로운 도구를 추가하려면 스크립트 내에서 아래 형식을 사용하세요.

**형식:**
`check_install "이름" "실행할 명령어"`

**예시:**
* **패키지 설치**: `check_install "htop" "sudo apt install -y htop"`
* **심볼릭 링크**: `check_install "python" "sudo ln -s $(which python3) /usr/bin/python"`
* **GitHub 설치**: `check_install "tabby" "install_gh_release Eugeny/tabby deb x64"`

## ⚠️ 참고
- 다시 설치하고 싶으면 `~/.custom_install_success` 파일을 삭제하세요.
