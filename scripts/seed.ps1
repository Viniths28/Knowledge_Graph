
# Runs /import/seed.cypher inside the container using cypher-shell
Param(
  [string]$User = $env:NEO4J_USER,
  [string]$Password = $env:NEO4J_PASSWORD
)
if (-not $User) { $User = "neo4j" }
if (-not $Password) { $Password = "changeMe_Strong!" }

docker compose exec neo4j-dev-kg /var/lib/neo4j/bin/cypher-shell -u $User -p $Password -f /import/seed.cypher
