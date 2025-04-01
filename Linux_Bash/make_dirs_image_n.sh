#!/bin/bash


cd $HOME

echo "Содержимое home директории:"
ls -ltr

if [ -n "$1" ]
then
  END=$1
else
  echo "Скрипт вызван без параметров, по умолчанию будет создано 100 директорий."
  END=100
fi

for i in $(seq 1 $END)
do
  mkdir "image$i"
done

echo "Содержимое home после создания директорий:"
ls -ltr

rm -rf image*

echo "Все созданные директории удалены."

