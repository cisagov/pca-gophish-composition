
git lfs install
winget install alpine

docker-compose pca-gophish-composition-cb-2025 -q | xargs docker save -o gophish-images.tar /

docker run --rm \
  -v source_volume_name:/data \
  -v $(pwd):/backup \
  alpine tar cvf /backup/volume_backup.tar /data

git checkout full-env-support
git lfs track "*.tar"
git add .gitattributes gophish-images.tar
git commit -m "Add lightweight stack export"
git push origin full-env-support