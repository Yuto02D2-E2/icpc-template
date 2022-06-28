#!/bin/sh

set -eu


function help() {
    echo -e "\nUsage:"
    echo -e "\tsh test.sh <problem char(UpperCase)> <options>"
    echo -e "\nOptions:"
    printf "\t-l <Language:\e[34mpython\e[m,cpp>\n"
    printf "\t-d <Data:\e[34sample\e[m,judge>\n"
    printf "\t-m <Mode:\e[34mrun\e[m,check,submit>\n"
    printf "# \e[34mblue\e[m is default value\n\n"
    exit 0
}


function compile() {
    if [ "$lang" == "cpp" ]; then
        echo -n "> compile..."
        g++ -std=gnu++17 -O2 -Wall -Wextra -D_GLIBCXX_DEBUG -Wno-unknown-pragmas -g -o ${problem}.bin ${problem}.cc
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
            python -O $problem.py < ${file};;
        "cpp" )
            ./$problem.bin < ${file};;
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
            python $problem.py < ${inputFiles[idx]} | tee result.txt;;
        "cpp" )
            ./$problem.bin < ${inputFiles[idx]} | tee result.txt;;
        esac
        echo -e "\n- expected :"
        cat ${answerFiles[idx]}
        if diff -sq result.txt ${answerFiles[idx]} >/dev/null; then
            printf "\n[ status ] : \e[32m AC \e[m\n"
        else
            printf "\n[ status ] : \e[31m WA \e[m\n"
            status="WA"
        fi
    }
    rm result.txt
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
        python $problem.py < ./judge/${inputFile} > ./submit/${inputFile}.answer;;
    "cpp" )
        ./$problem.bin < ./judge/${inputFile} > ./submit/${inputFile}.answer;;
    esac
    printf "\e[34m done\e[m\n"
    echo -e "> let's submit the file : ${inputFile}.answer\n"
}


#------------------- entry point. main process below ------------------------
if [ "$#" -lt 1 ]; then
    # TODO: 半角大文字一文字(A,B,...H)以外を弾く
    printf ">\e[31m invalid args\e[m: problem char(UpperCase) is required\n"
    help
fi

problem=${1}
shift 1 # skip reading problem char
lang="python"
data="sample"
mode="run"
while getopts :l:d:m:h OPT; do
    case ${OPT} in
    "l" ) lang="${OPTARG}";;  # programming language
    "d" ) data="${OPTARG}";;  # path to input data
    "m" ) mode="${OPTARG}";;  # run only / check / make submit data
    "h" | * )
        printf ">\e[31m invalid args\e[m\n";
        help;;
    esac
done

echo -e "\n> problem:${problem} / lang:${lang} / data:${data} / mode:${mode}\n"

compile # call compile func

case ${mode} in
"run" ) run;;
"check" ) check;;
"submit" ) submit;;
esac

exit 0
# end of script
