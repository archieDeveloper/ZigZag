#/bin/sh
rm -rf tmp_dir
mkdir tmp_dir
cp -r src tmp_dir/
cp -r bin tmp_dir/
cp *.as3proj tmp_dir/
rm -rf `find tmp_dir/* -name '.*'`
zip -r APIConnection.zip tmp_dir/*
chmod 644 APIConnection.zip
rm -rf tmp_dir
mv -v APIConnection.zip ~/data/static/source