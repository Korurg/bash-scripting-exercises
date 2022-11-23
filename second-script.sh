#!/bin/bash

#example: ./second-script.sh 'ya.ru' 'https://www.litres.ru/gettrial/?art=49592199&format=txt&lfrom=159481197'

LOGFILE='logs'
ERRORLOG='logs-errors'

process-command() {
  "$@"
  if [ $? == '0' ]; then
    echo "command $@ exit with code $?" >>"$LOGFILE"
  else
    echo "command $@ exit with code $?" >>"$ERRORLOG"
  fi
}

request() {
  process-command curl -w '%{json}\n' "$1"
}

#Проверяем переданные аргументы, и если они не указаны, пишем в лог и выходим
if [ -z $1 ] || [ -z $2 ]; then
  echo 'one or both arguments is empty' | tee -a "$LOGFILE"
  exit 1
fi

#Качаем архив из https://avidreaders.ru/download/voyna-i-mir-tom-1.html?f=txt . Т.к. сам файл качается через вызов js, указываем URL файла
process-command curl --output war-and-peace.zip 'https://www.litres.ru/gettrial/?art=49592199&format=txt&lfrom=159481197'

#Распаковываем скаченный архив
process-command unzip war-and-peace.zip
process-command rm -v war-and-peace.zip

#Для удобства переименовываем в понятное название
process-command mv 59495692.txt war-and-peace.txt

#Меняем кодировку на UTF-8
process-command iconv -c -f WINDOWS-1251 -t UTF-8 war-and-peace.txt -o war-and-peace-utf8.txt
process-command mv war-and-peace-utf8.txt war-and-peace.txt

#Приводим в нижнему регистру, удаляем знаки пунктуации, удаляем символ возврата коретки, переносим каждое слово на новую строку, удаляем пустые строки
awk '{print tolower($0)}' war-and-peace.txt | awk '{gsub(/[[:punct:]]/, "")} 1' | awk '{gsub("\r", "")} 1' | awk '{gsub(" ", "\n")} 1' | awk NF >war-and-peace-words.txt
#Подсчитываем количество слов, сортируем по частоте, удаляем пробелы в начале, которые добавляет uniq -c
sort war-and-peace-words.txt | uniq -c -d | sort -n -r -k 1 | awk '{gsub(/^[ \t]+/, "")} 1' >war-and-peace-words-temp.txt
process-command mv war-and-peace-words-temp.txt war-and-peace-words.txt

#Во втором столбце находим слова, которые больше 5 символов
TOP5=$(awk '{print $2}' war-and-peace-words.txt | awk '/......*/' | head -n 5)

echo '5 популярных слов : ' $TOP5

#Если есть слово "князь", делаем запрос
if echo "$TOP5" | grep 'князь' >/dev/null; then
  request ya.ru
fi

#Если нет слова "говорил", делаем запрос
if ! echo "$TOP5" | grep 'говорил' >/dev/null; then
  request google.coom
fi

if [ ! -d ./download ]; then
  mkdir download
  echo "create dir \"download\" in $(pwd)" >>"$LOGFILE"
fi

#Делаем запрос по первому аргументу, и скачиваем файл по второму аргументу
request "$1"
FILENAME=$(process-command curl --output-dir ./download -OJ --connect-timeout 5 -w "%{filename_effective}" "$2")

echo "relative path : $(realpath --relative-to=$(pwd) ./download/$FILENAME)" #тут на самом деле можно написать просто echo "./$FILENAME", т.к. по условию задания файл скачивается в подпапку download
echo "absolute path : $(realpath ./download/$FILENAME)"
echo "file info : $(ls -lh ./download/$FILENAME)"