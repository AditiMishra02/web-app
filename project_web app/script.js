function queryData() {
    const queryForm = document.getElementById("query-form");
    const queryRollNumber = queryForm.query_roll_number.value;

    fetch(`query_data.php?roll_number=${queryRollNumber}`)
        .then(response => response.json())
        .then(data => {
            const queryResult = document.getElementById("query-result");

            if (data.error) {
                queryResult.innerHTML = data.error;
            } else {
                queryResult.innerHTML = `
                    <h3>Query Result:</h3>
                    <p>Name: ${data.name}</p>
                    <p>Email: ${data.email}</p>
                    <p>Roll Number: ${data.roll_number}</p>
                    <p>Timestamp: ${data.timestamp}</p>
                `;
            }
        })
        .catch(error => {
            console.error("Error:", error);
        });
}
