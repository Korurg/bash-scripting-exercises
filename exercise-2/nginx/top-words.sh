#!/bin/bash

LOGFILE='logs'
ERRORLOG='logs-errors'

process-command() {
  "$@"
  if [ $? == '0' ]; then
    echo "command $* exit with code $?" >>"$LOGFILE"
  else
    echo "command $* exit with code $?" >>"$ERRORLOG"
  fi
}

#Качаем архив из https://avidreaders.ru/download/voyna-i-mir-tom-1.html?f=txt . Т.к. сам файл качается через вызов js, указываем URL файла
process-command curl --output war-and-peace.zip 'https://www.litres.ru/gettrial/?art=49592199&format=txt&lfrom=159481197'

#Распаковываем скаченный архив
process-command unzip -q war-and-peace.zip
process-command rm war-and-peace.zip

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
TOP1=$(awk '{print $2}' war-and-peace-words.txt | awk '/......*/' | head -n 1)

process-command rm war-and-peace-words.txt
process-command rm war-and-peace.txt

echo 'top word : ' "$TOP1"