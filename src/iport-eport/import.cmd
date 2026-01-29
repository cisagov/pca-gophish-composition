docker load -i gophis-images.tar

docker volume create source_volume_name

docker run --rm \
  -v source_volume_name:/data \
  -v $(pwd):/backup \
  alpine tar xvf /backup/volume_backup.tar -C /