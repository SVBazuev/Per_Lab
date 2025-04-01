#!/bin/bash

new_dir="images"
images=('loose-curly-afro.jpg' 'shaved.jpg' 'one-length-midi.jpg' 'sharp-layers.jpg' 'the-side-shave.jpg')


cd $HOME
mkdir $new_dir
cd $new_dir

for i in ${images[@]};
do
  wget "https://www.generatormix.com/images/haircut/${i}"
done

tar -cf "${new_dir}.tar" "${images[@]}"

echo "Загруженые картинки упакованы в архив ~/${new_dir}/${new_dir}.tar"
echo "Список содержимого архива:"
tar -tf "${new_dir}.tar"

cd $HOME

rm -r "$new_dir"

echo "Директория  ~/${new_dir} - удалена."
