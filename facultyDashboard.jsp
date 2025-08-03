<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.sql.*" %>
<%@ page import="db.DBConnection" %>

<%
    String fid = (String) session.getAttribute("faculty_id");
    String department = (String) session.getAttribute("faculty_department");

    List<Map<String, String>> subjectList = new ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        String sql = "SELECT subject_id, subject_name FROM subjects WHERE dept = ? AND fid = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, department);
            ps.setString(2, fid);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> subject = new HashMap<>();
                    subject.put("id", rs.getString("subject_id"));
                    subject.put("name", rs.getString("subject_name"));
                    subjectList.add(subject);
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<html>
<head>
    <title>Faculty Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(to bottom right, #e0f7fa, #ffffff);
            margin: 0;
            padding: 20px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header h2 {
            color: #333;
            margin: 0;
        }
        .back-button {
            background-color: #0277bd;
            color: white;
            padding: 8px 12px;
            border: none;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
        }
        .back-button:hover {
            background-color: #01579b;
        }
        form {
            background-color: #f9f9f9;
            padding: 20px;
            border: 1px solid #ccc;
            width: 420px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        label {
            display: block;
            margin-top: 10px;
            font-weight: bold;
        }
        input[type="text"],
        select {
            width: 100%;
            padding: 8px;
            margin-top: 5px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        input[type="submit"] {
            background-color: #00796b;
            color: white;
            padding: 10px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #004d40;
        }
    </style>
</head>
<body>
    <div class="header">
        <h2>Faculty Dashboard - Welcome <%= fid %></h2>
        <a href="index.jsp" class="back-button">Back to Home</a>
    </div>

   <form action="enterMarks.jsp" method="post">

        <label for="subject">Select Subject:</label>
        <select name="subject_id" id="subject" required onchange="updateSubjectName(this)">
            <option value="">-- Select Subject --</option>
            <% for (Map<String, String> subject : subjectList) { %>
                <option value="<%= subject.get("id") %>" data-subjectname="<%= subject.get("name") %>">
                    <%= subject.get("name") %>
                </option>
            <% } %>
        </select>

        <input type="hidden" name="subject_name" id="subject_name">

        <label>Semester:</label>
        <input type="text" name="sem" required>

        <label>Year:</label>
        <input type="text" name="year" required>

        <label>Batch Year:</label>
        <input type="text" name="batch_year" required>

        <!-- Hidden field for faculty department -->
        <input type="hidden" name="faculty_department" value="<%= department %>">

        <input type="submit" value="Enter Marks">
    </form>
    
    

    <script>
        function updateSubjectName(select) {
            var selectedOption = select.options[select.selectedIndex];
            var subjectName = selectedOption.getAttribute("data-subjectname");
            document.getElementById("subject_name").value = subjectName;
        }
    </script>
</body>
</html>

