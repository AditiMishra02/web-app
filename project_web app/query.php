

<?php $servername = "server";

$username = "aditi";
$password = "aditi202";
$dbname = "student_data";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$query_roll_number = $_GET['roll_number'];

$query = "SELECT * FROM student_data WHERE roll_number = '$query_roll_number'";

$result = $conn->query($query);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode($row);
} else {
    echo json_encode(["error" => "No data found for the provided roll number."]);
}

$conn->close();
?>
