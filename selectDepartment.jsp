<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Select Department</title>
</head>
<body>
    <h2>Select Your Department</h2>
    <form action="facultyLogin.jsp" method="post">
        <label for="department">Department:</label>
        <select name="department" required>
            <option value="">--Select Department--</option>
            <option value="MCA">MCA</option>
            <option value="MBA">MBA</option>
            <!-- Add more departments if needed -->
        </select>
        <br><br>
        <input type="submit" value="Proceed to Login">
    </form>
</body>
</html>
