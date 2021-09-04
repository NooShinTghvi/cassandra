<?php
$cluster = Cassandra::cluster()
    ->withContactPoints('database')
    ->withPort(9042)
    ->build();

$session = $cluster->connect();

$createKeyspace = <<<EOD
CREATE KEYSPACE measurements
WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 1
}
EOD;

$createTable = <<<EOD
CREATE TABLE events (
  id INT,
  col1 VARCHAR,
  col2 VARCHAR,
  PRIMARY KEY (id)
)
EOD;

//$session->execute($createKeyspace);
$session->execute('USE measurements');
//$session->execute($createTable);

$batch = new Cassandra\BatchStatement();

$batch->add(
    "INSERT INTO events (id, col1, col2) VALUES (1, ?, ?)",
    array('hello', 'world')
);

$session->execute($batch);

?>