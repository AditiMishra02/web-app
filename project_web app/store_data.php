<?php
$servername = "localhost";
$username = "aditi";
$password = "aditi202";
$dbname = "student_data";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$name = $_POST['name'];
$email = $_POST['email'];
$roll_number = $_POST['roll_number'];

$query = "REPLACE INTO student_data (roll_number, name, email, timestamp) VALUES ('$roll_number', '$name', '$email', NOW())";

if ($conn->query($query) === TRUE) {
    echo "Data stored successfully.";
} else {
    echo "Error: " . $query . "<br>" . $conn->error;
}

$conn->close();
?>
