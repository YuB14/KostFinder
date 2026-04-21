<?php
$ch = curl_init('http://127.0.0.1:8000/api/dashboard/registrations');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$res = curl_exec($ch);
echo "Registrations:\n";
echo $res . "\n";
