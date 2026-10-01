
$stunnelConfig="./\AppData\Local\Programs\stunnel\config"
docker run -d -p 6379:6379 -v $stunnelConfig`:/certs --name redis-tls madflojo/redis-tls