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
$roll = $_POST['roll'];
$timestamp = date("Y-m-d H:i:s");

$sql = "INSERT INTO student_data (name, email, roll, timestamp) VALUES ('$name', '$email', '$roll', '$timestamp')
    ON DUPLICATE KEY UPDATE email='$email', timestamp='$timestamp'";

if ($conn->query($sql) === TRUE) {
    echo "Data stored successfully!";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
