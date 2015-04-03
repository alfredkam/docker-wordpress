<?php
$link = mysql_connect(getenv('DB_HOST') . ':' . getenv('DB_PORT'), getenv('DB_USER'), getenv('DB_PASSWORD'));

echo getenv('DB_HOST') . ':' . getenv('DB_PORT');
echo getenv('DB_USER');
echo getenv('DB_PASSWORD');

if (!$link) {
    die('Could not connect: ' . mysql_error());
}
echo 'Connected successfully';
mysql_close($link);
?>
}>
