#!/bin/sh

set -eu
# MEMO:
# -e: exit(0)以外でコマンドが終了した場合にスクリプトを停止
# -u: 未定義の変数を使った時にスクリプトを停止


function help() {
    echo -e "\nUsage:"
    echo -e "\tsh test.sh <problem char> <options>"
    echo -e "\nOptions:"
    printf "\t-e <ExecFile:\e[34mProblemChar.py\e[m,ProblemChar.exe>\n"
    printf "\t-l <Language:\e[34mpython\e[m,cpp>\n"
    printf "\t-d <Data:\e[34msample\e[m,judge>\n"
    printf "\t-m <Mode:\e[34mrun\e[m,check,submit>\n"
    printf "# \e[34mblue\e[m is default value\n\n"
    exit 0
}


function compile() {
    if [ "$lang" == "cpp" ]; then
        echo -n "> compile..."
        g++ -std=gnu++17 -O2 -Wall -Wextra -D_GLIBCXX_DEBUG -Wno-unknown-pragmas -g -o ${execFile} ${problem}.cc
        case ${?} in
        "0" ) printf "\e[34m passed \e[m\n";;
        * ) exit 0;;
        esac
    fi
}


function run() {
    # 実行するだけ(答え合わせはしない)
    local inputFiles=()
    for file in $(find ./${data}/ -type f -name "${problem}*" ! -name "*.*"); do
        inputFiles+=(${file})
    done
    for file in $inputFiles; do
        if [ ! -s ${file} ]; then
            # ファイルが空なら
            break
        fi
        case ${lang} in
        "python" )
            python -O $execFile < ${file};;
        "cpp" )
            ./$execFile < ${file};;
        esac
    done
}


function check() {
    # 実行して，答え合わせする
    local inputFiles=()
    local answerFiles=()
    for file in $(find ./${data}/ -type f -name "${problem}*" ! -name "*.*"); do
        inputFiles+=(${file})
    done
    for file in $(find ./${data}/ -type f -name "${problem}*.ans"); do
        answerFiles+=(${file})
    done
    local status="AC"
    for ((idx=0; idx < "${#inputFiles[*]}"; idx++)) {
        if [ ! -s ${inputFiles[idx]} ]; then
            # ファイルが空なら
            break
        fi
        echo -e "\n\n- result :"
        case ${lang} in
        "python" )
            python $execFile < ${inputFiles[idx]} | tee result.txt;;
        "cpp" )
            ./$execFile < ${inputFiles[idx]} | tee result.txt;;
        esac
        echo -e "\n- expected :"
        cat ${answerFiles[idx]}
        set +e
        diff --strip-trailing-cr result.txt ${answerFiles[idx]} > /dev/null
        # MEMO: --strip-trailing-cr オプションでLF/CRLFの改行コードによる差を無視する
        if [ ${?} -eq 0 ]; then
            printf "\n[ status ] : \e[32m AC \e[m\n"
        else
            printf "\n[ status ] : \e[31m WA \e[m\n"
            status="WA"
        fi
        set -e
    }
    # rm result.txt
    case ${status} in
    "AC" ) printf "\n[ final status ] : \e[32m AC \e[m\n";;
    "WA" ) printf "\n[ final status ] : \e[31m WA \e[m\n";;
    esac
}


function submit() {
    # judge/以下のファイルから，提出用ファイルを作成する
    read -p "enter data number [1|2|3|4]:" dataNumber
    local inputFile=${problem}${dataNumber}
    echo -n "> make submit data..."
    case ${lang} in
    "python" )
        python $execFile < ./judge/${inputFile} > ./submit/${inputFile}.answer;;
    "cpp" )
        ./$execFile < ./judge/${inputFile} > ./submit/${inputFile}.answer;;
    esac
    printf "\e[34m done\e[m\n"
    echo -e "> let's submit the file : ${inputFile}.answer\n"
}


#------------------- entry point. main process below ------------------------
if [ "$#" -lt 1 ]; then
    printf ">\e[31m invalid args\e[m: problem char(e.g. A,B,...,H) is required\n"
    help
fi

problem=${1^^} # cast to upper case
shift 1 # skip reading problem char
lang="python"
data="sample"
mode="run"
while getopts :e:l:d:m:h OPT; do
    case ${OPT} in
    "e" ) execFile="${OPTARG}";; # .py / .exe file name
    "l" ) lang="${OPTARG}";;  # programming language
    "d" ) data="${OPTARG}";;  # path to input data
    "m" ) mode="${OPTARG}";;  # run only / check / make submit data
    "h" | * )
        printf ">\e[31m invalid args\e[m\n";
        help;;
    esac
done

case ${lang} in
"python" ) execFile="${problem,,}.py" ;; # cast to lower case
"cpp" ) execFile="${problem,,}.bin" ;;
esac

echo -e "\n> problem:${problem} / lang:${lang} / data:${data} / mode:${mode}\n"

compile # call compile func

case ${mode} in
"run" ) run;;
"check" ) check;;
"submit" ) submit;;
esac

exit 0
# end of script

